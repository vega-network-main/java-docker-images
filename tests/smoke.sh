#!/usr/bin/env bash
# Usage: tests/smoke.sh IMAGE [IMAGE...]
# Runs the image contract checks plus tests/Smoke.java (fonts + JNI) in each image.
# ENTRYPOINT_OVERRIDE=path/to/entrypoint.sh mounts that script over the image's own,
# to test entrypoint changes without rebuilding every image.
set -uo pipefail

if [[ -n "${ENTRYPOINT_OVERRIDE:-}" ]]; then
  ENTRYPOINT_OVERRIDE=$(realpath -e "$ENTRYPOINT_OVERRIDE") || exit 2
fi
cd "$(dirname "$0")"
CACHE="$PWD/.cache"
JDK_IMAGE="eclipse-temurin:21-jdk"
MAVEN="https://repo1.maven.org/maven2"
NETTY="4.2.19.Final"

# Native-library jars that game servers load through JNI. Pinned by SHA-256.
JARS=(
  "bcb1f51e36f940867e83342f9efbf5968ac44a6bef4d397bb4af7b17b45cd2fb org/xerial/sqlite-jdbc/3.53.4.0/sqlite-jdbc-3.53.4.0.jar"
  "22fa74761f6e35c8c88972f35cf65664566b922dd73d3424528e97c34278fa79 io/netty/netty-common/$NETTY/netty-common-$NETTY.jar"
  "863f09b46cfe7d83872c9499086b9681cd9878c30a319d9f1f3a681bbfb0b12f io/netty/netty-buffer/$NETTY/netty-buffer-$NETTY.jar"
  "3ded47536faeb3c4c544a84871d82f461511589afb2a892a180ca425f281363e io/netty/netty-resolver/$NETTY/netty-resolver-$NETTY.jar"
  "d82d4e200456b8c5d8a1647a3724603f80616e5b35b9ada6e7a20d048f175075 io/netty/netty-transport/$NETTY/netty-transport-$NETTY.jar"
  "341e91b8e69e6b7d92c353c845ffd91f34e921b7186254c176a64c7089b3e721 io/netty/netty-transport-native-unix-common/$NETTY/netty-transport-native-unix-common-$NETTY.jar"
  "4d96ba8dd98ace998f6ae7bfe53ae9e581bd92ad2f7ebe5bd994d1a24306db7e io/netty/netty-transport-classes-epoll/$NETTY/netty-transport-classes-epoll-$NETTY.jar"
  "3dd01532f34540676c9e0153f96a44c78a73f2b0118ef46cb14247e512dde76b io/netty/netty-transport-native-epoll/$NETTY/netty-transport-native-epoll-$NETTY-linux-x86_64.jar"
  "e3e69412243f28942dac2d1772e5be72302cc0123fd58a31f357e1eef9d2bfa5 io/netty/netty-transport-native-epoll/$NETTY/netty-transport-native-epoll-$NETTY-linux-aarch_64.jar"
)

RUN=(docker run --rm)
if [[ -n "${ENTRYPOINT_OVERRIDE:-}" ]]; then
  RUN+=(-v "$ENTRYPOINT_OVERRIDE:/entrypoint.sh:ro")
fi

TOOLS="bash curl git ip tar openssl sqlite3 fc-list"

# Shell/locale noise from the entrypoint. Java's own WARNING lines are not matched.
FORBIDDEN='setlocale|cannot change locale|command not found|No such file or directory|Permission denied'

prepare() {
  mkdir -p "$CACHE/lib" "$CACHE/classes"
  local entry sum path file
  for entry in "${JARS[@]}"; do
    read -r sum path <<<"$entry"
    file="$CACHE/lib/$(basename "$path")"
    if ! echo "$sum  $file" | sha256sum -c --status 2>/dev/null; then
      curl -fsSL --retry 3 -o "$file" "$MAVEN/$path" || { echo "download failed: $path" >&2; exit 2; }
      echo "$sum  $file" | sha256sum -c --status || { echo "checksum mismatch: $path" >&2; exit 2; }
    fi
  done
  if [[ ! -f "$CACHE/classes/Smoke.class" || Smoke.java -nt "$CACHE/classes/Smoke.class" ]]; then
    docker image inspect "$JDK_IMAGE" >/dev/null 2>&1 || docker pull -q "$JDK_IMAGE" >/dev/null
    docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/src" -w /src "$JDK_IMAGE" \
      javac --release 8 -Xlint:-options -d .cache/classes Smoke.java || { echo "javac failed" >&2; exit 2; }
  fi
  chmod -R a+rX "$CACHE"
  CLASSPATH_IN_IMAGE="/smoke/classes"
  for file in "$CACHE"/lib/*.jar; do
    CLASSPATH_IN_IMAGE+=":/smoke/lib/$(basename "$file")"
  done
}

test_image() {
  local image=$1 out rc ok=1

  out=$(docker run --rm --entrypoint sh "$image" -c "
    id -un
    for t in $TOOLS; do command -v \$t >/dev/null || echo \"missing tool: \$t\"; done
    fc-list | grep -qi 'DejaVu' || echo 'fc-list: no DejaVu fonts'
    touch /home/container/.write-test 2>/dev/null || echo 'home not writable'
  " 2>&1)
  if [[ "$(head -n1 <<<"$out")" != "container" ]]; then
    echo "  FAIL user: expected container, got '$(head -n1 <<<"$out")'"; ok=0
  fi
  if grep -E '^(missing tool|fc-list|home not)' <<<"$out" | sed 's/^/  FAIL /'; then ok=0; fi

  # Panel variable values must never run as code, while the egg's own quoting is kept.
  out=$("${RUN[@]}" -e 'EVIL=$(echo INJECTED)' \
    -e STARTUP='printf "<%s>" {{EVIL}} "a b" "*"; echo' "$image" 2>&1)
  if ! grep -qxF '<$(echo><INJECTED)><a b><*>' <<<"$out"; then
    echo "  FAIL entrypoint parsing: got $(tail -n1 <<<"$out")"; ok=0
  fi

  # The server must be PID 1 so the stop signal from Wings reaches it, and its exit code must come back.
  out=$("${RUN[@]}" -e STARTUP="sh -c 'echo pid=\$\$; exit 7'" "$image" 2>&1)
  rc=$?
  if ! grep -qx 'pid=1' <<<"$out" || (( rc != 7 )); then
    echo "  FAIL entrypoint exec: expected pid=1 and exit 7, got '$(tail -n1 <<<"$out")' exit $rc"; ok=0
  fi

  out=$("${RUN[@]}" -v "$CACHE:/smoke:ro" -e SMOKE_CP="$CLASSPATH_IN_IMAGE" \
    -e STARTUP='java -Djava.awt.headless=true -cp {{SMOKE_CP}} Smoke' \
    "$image" 2>&1)
  rc=$?
  sed 's/^/  | /' <<<"$out"
  if (( rc != 0 )) || ! grep -q '^SMOKE OK$' <<<"$out"; then
    echo "  FAIL smoke: exit $rc"; ok=0
  fi
  if ! grep -qE '\[[^]@]+@image\]' <<<"$out"; then
    echo "  FAIL entrypoint: GITHUB_USER is empty in the [user@image] prefix"; ok=0
  fi
  if grep -E "$FORBIDDEN" <<<"$out" | sed 's/^/  FAIL output: /'; then ok=0; fi

  (( ok ))
}

(( $# > 0 )) || { echo "usage: $0 IMAGE [IMAGE...]" >&2; exit 2; }
prepare

failed=()
for image in "$@"; do
  echo "== $image"
  if test_image "$image"; then echo "  OK"; else failed+=("$image"); fi
done

echo
if (( ${#failed[@]} )); then
  echo "FAILED (${#failed[@]}/$#):"; printf '  %s\n' "${failed[@]}"
  exit 1
fi
echo "ALL PASSED ($#)"

#!/bin/bash

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container || exit 1

PREFIX=$(printf '\033[1m\033[91m[%s@image] \033[0m' "${GITHUB_USER}")

printf '%sjava -version\n' "${PREFIX}"
java -version

# Wings hands over the egg's startup line with {{VARIABLE}} placeholders and sets each
# variable as an env var. Rewriting {{X}} to ${X} and letting one shell parse the line
# expands every value exactly once: a value is never parsed as shell code, while the
# egg's own line keeps normal shell quoting.
PLACEHOLDER='\{\{([A-Za-z_][A-Za-z0-9_]*)\}\}'
COMMAND=$(sed -E "s/${PLACEHOLDER}/\${\1}/g" <<<"${STARTUP}")

# Same substitution for the console line, done as plain text so nothing is executed.
SHOWN=""
REST=${STARTUP}
while [[ ${REST} =~ ${PLACEHOLDER} ]]; do
    NAME=${BASH_REMATCH[1]}
    SHOWN+=${REST%%"${BASH_REMATCH[0]}"*}${!NAME:-}
    REST=${REST#*"${BASH_REMATCH[0]}"}
done
SHOWN+=${REST}

printf '%s%s\n' "${PREFIX}" "${SHOWN}"

# exec, so the server (not this script) receives the stop signal from Wings.
exec bash -c "${COMMAND}"

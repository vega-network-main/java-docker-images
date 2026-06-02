![Монтажная область 12](https://github.com/vega-network-main/java-docker-images/assets/61664874/4d523ea9-6fe1-4591-88f3-289f336560a9)
# ☕ Java Docker Images for Pterodactyl

Lightweight, multivendor Java Docker images tailored for: [Pterodactyl](https://pterodactyl.io/), [Pelican](https://pelican.dev/) panels.

From **June 29, 2025**, we’re migrating all images to **Alpine Linux** where possible.
Currently migrating: GraalVM and Adoptium

Liberica uses [Alpaquita linux](https://bell-sw.com/alpaquita-linux/)

---

## 🛠️ Features

* JDK and JRE variants
* Multi-version support (Java 8 → 24+)
* Compatible with containerized game and app hosting

---

## 📦 Vendors

Each vendor has its own folder:

* `/Adoptium`        - [README](https://github.com/vega-network-main/java-docker-images/blob/main/Adoptium/README.MD)
* `/Amazon Corretto` - [README](https://github.com/vega-network-main/java-docker-images/blob/main/Amazon%20Corretto/README.MD)
* `/Azul Zulu`       - [README](https://github.com/vega-network-main/java-docker-images/blob/main/Azul%20Zulu/README.MD)
* `/GraalVM`         - [README](https://github.com/vega-network-main/java-docker-images/blob/main/GraalVM/README.MD)
* `/Liberica`        - [README](https://github.com/vega-network-main/java-docker-images/blob/main/Liberica/README.MD)
* `/OpenJDK`         - [README](https://github.com/vega-network-main/java-docker-images/blob/main/OpenJDK/README.MD) (DEPRECATED - We will not update this image anymore files of it were removed but GHCR images are still available)

Inside each:

```shell
/java-version[-jre]/Dockerfile
```

Liberica uses universal:

```shell
/Dockerfile
```

---

## ✅ Why sudden switch to Alpine?

* Smaller image sizes (usually debian based images are around 450-850MB, alpine on other hand from 167-389MB)
* Faster startup and deploys

---

## 🚀 Usage Example

```dockerfile
FROM ghcr.io/vega-network-main/java-docker-images:openjdk-17-jre-alpine
USER container # not always needed
COPY my-app.jar /app.jar
CMD ["java", "-jar", "/app.jar"]
```

---

## 🤝 Contributing

We welcome pull requests and improvements!

* Fork and submit PRs
* Add support for new versions or vendors
* Review or suggest Dockerfile optimizations

---

## 📄 License

![MIT](https://img.shields.io/badge/license-MIT-green)

---

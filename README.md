# Building a local hadoop system

Let's build a local hadoop system step by step.

## Docker Installation

Download [docker desktop](https://www.docker.com/) then install.

## Source Mirror

![daemon-setting](./images/daemon.png)

Open docker desktop, in the settings page, search `daemon` and change the settings to content below:

```json
{
    "builder": {
        "gc": {
            "defaultKeepStorage": "20GB",
            "enabled": true
        }
    },
    "experimental": false,
    "registry-mirrors": [
        "https://docker.xuanyuan.me",
        "https://docker.m.daocloud.io",
        "https://docker.xuanyuan.me",
        "https://docker.1ms.run",
        "https://docker.1panel.live",
        "https://hub.rat.dev",
        "https://docker-mirror.aigc2d.com"
    ]
}
```

## Build hadoop:base image

First build `hadoop:base`:

```bash
docker buildx build \
    --load \
    --network host \
    -t hadoop:base \
    -f docker/Dockerfiles/Dockerfile.base \
    .
```

## Build the Cluster

Then compose:

```bash
docker compose up -d --build
```

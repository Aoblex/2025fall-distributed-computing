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

## Build Images

```bash
docker buildx build \
    --load \
    --network host \
    -t hadoop:base \
    -f docker/Dockerfiles/Dockerfile.base \
    .

docker buildx build \
    --load \
    --network host \
    -t hadoop:datanode \
    -f docker/Dockerfiles/Dockerfile.datanode \
    .

docker buildx build \
    --load \
    --network host \
    -t hadoop:jobhistoryserver \
    -f docker/Dockerfiles/Dockerfile.jobhistoryserver \
    .

docker buildx build \
    --load \
    --network host \
    -t hadoop:namenode \
    -f docker/Dockerfiles/Dockerfile.namenode \
    .

docker buildx build \
    --load \
    --network host \
    -t hadoop:resourcemanager \
    -f docker/Dockerfiles/Dockerfile.resourcemanager \
    .
```

## Build the Cluster

Then compose:

```bash
docker compose up -d
```

To stop the cluster, run:

```bash
docker compose down
```

## Running the Cluster

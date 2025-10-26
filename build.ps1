#!/usr/bin/env pwsh
docker buildx build `
    --load `
    --network host `
    -t hadoop:base `
    -f docker/Dockerfiles/Dockerfile.base `
    .

docker buildx build `
    --load `
    --network host `
    -t hadoop:datanode `
    -f docker/Dockerfiles/Dockerfile.datanode `
    .

docker buildx build `
    --load `
    --network host `
    -t hadoop:jobhistoryserver `
    -f docker/Dockerfiles/Dockerfile.jobhistoryserver `
    .
docker buildx build `
    --load `
    --network host `
    -t hadoop:namenode `
    -f docker/Dockerfiles/Dockerfile.namenode `
    .

docker buildx build `
    --load `
    --network host `
    -t hadoop:resourcemanager `
    -f docker/Dockerfiles/Dockerfile.resourcemanager `
    .

docker buildx build --network host --progress=plain --debug --platform=linux/arm64 -t hadoop:base -f ./docker/Dockerfiles/Dockerfile.base .

docker compose up -d
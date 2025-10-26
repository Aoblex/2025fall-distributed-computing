First build `hadoop:base`:

```bash
docker buildx build \
    --load \
    -t hadoop:base \
    -f docker/Dockerfiles/Dockerfile.base \
    .
```

Then compose:

```bash
docker compose up -d --build
```

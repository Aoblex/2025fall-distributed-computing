#!/usr/bin/env bash
set -euo pipefail

# Enable Docker BuildKit for architecture-specific builds.
export DOCKER_BUILDKIT=1

ARCH=$(uname -m)
case "$ARCH" in
	x86_64|amd64)
		PLATFORM=linux/amd64
		;;
	aarch64|arm64)
		PLATFORM=linux/arm64
		;;
	*)
		echo "Warning: unknown arch '$ARCH', defaulting to linux/amd64"
		PLATFORM=linux/amd64
		;;
esac

echo "Building hadoop:base for platform: $PLATFORM"
docker buildx build --network host --progress=plain --debug --platform="$PLATFORM" -t hadoop:base -f ./docker/Dockerfiles/Dockerfile.base .
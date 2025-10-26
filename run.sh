#!/usr/bin/env bash
set -euo pipefail

# Detect host CPU architecture and map to an explicit docker platform string.
# This avoids hard-coding "linux/arm64" while still providing an explicit
# --platform to docker buildx when useful.
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
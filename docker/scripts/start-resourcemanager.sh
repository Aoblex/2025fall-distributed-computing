#!/usr/bin/env bash
set -euo pipefail

/usr/sbin/sshd || true

yarn resourcemanager

exec bash
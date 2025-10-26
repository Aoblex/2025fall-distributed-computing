#!/usr/bin/env bash
set -euo pipefail

/usr/sbin/sshd || true

mapred historyserver

exec bash
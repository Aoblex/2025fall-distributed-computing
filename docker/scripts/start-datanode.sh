#!/usr/bin/env bash
set -euo pipefail

mkdir -p /root/hadoop/dfs/data

/usr/sbin/sshd || true

hdfs datanode

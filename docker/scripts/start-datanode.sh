#!/usr/bin/env bash
set -euo pipefail

mkdir -p /root/hadoop/dfs/data

/usr/sbin/sshd || true

# Start YARN NodeManager alongside DataNode
(yarn nodemanager &)

hdfs datanode

exec bash

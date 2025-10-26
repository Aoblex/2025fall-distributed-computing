#!/usr/bin/env bash
set -euo pipefail

mkdir -p /root/hadoop/dfs/name

if [ ! -d "/root/hadoop/dfs/name/current" ]; then
  echo "Formatting NameNode..."
  hdfs namenode -format -force -nonInteractive
fi

/usr/sbin/sshd || true

hdfs namenode

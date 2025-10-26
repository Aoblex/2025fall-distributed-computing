#!/usr/bin/env bash
set -e

# Minimal entrypoint: seed SSH keys, start sshd, and initialize NameNode if this is the namenode.

# Ensure SSH dir and key
mkdir -p /root/.ssh
chmod 700 /root/.ssh
if [ ! -f /root/.ssh/id_rsa ]; then
  ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa
fi
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys 2>/dev/null || true
chmod 600 /root/.ssh/authorized_keys || true

# Start sshd
mkdir -p /var/run/sshd
/usr/sbin/sshd
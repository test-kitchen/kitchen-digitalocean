#!/bin/bash
# monitoring: true installs the DigitalOcean metrics agent. The install happens
# at first boot, so it races the transport and needs a wait.
set -euo pipefail

# The DigitalOcean metadata service is what the Droplet itself was told at
# creation time, so it is the closest thing to reading back the request the
# driver sent, and it needs no credentials on the Droplet.
#
# This preamble is repeated in every script on purpose: the shell provisioner
# uploads only the file it is pointed at, so there is nothing to source.
metadata() { curl -sf --max-time 15 "http://169.254.169.254/metadata/v1/$1"; }
metadata_json() { curl -sf --max-time 15 "http://169.254.169.254/metadata/v1.json"; }
fail() { echo "FAIL: $*" >&2; exit 1; }

# Retries until the command succeeds or the attempts run out. Anything driven
# by cloud-init races the transport becoming available, so sampling once is a
# flake waiting to happen.
retry() {
  local attempts=$1 i
  shift
  for ((i = 1; i <= attempts; i++)); do
    "$@" && return 0
    sleep 5
  done
  return 1
}

echo "== monitoring =="

if ! retry 36 systemctl is-active --quiet do-agent; then
  systemctl status do-agent --no-pager || true
  fail "the do-agent service is not running, so monitoring was not enabled"
fi

systemctl is-active do-agent
echo "OK: monitoring"

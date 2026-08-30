#!/bin/bash
# ipv6: true gets the Droplet a routable v6 address. Reading it off the
# interface rather than out of the metadata proves the address was configured,
# not merely requested.
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

echo "== ipv6 =="
ip -6 addr show scope global || true

if ! retry 12 bash -c "ip -6 addr show scope global | grep -q inet6"; then
  fail "no global IPv6 address was configured"
fi

ip -6 addr show scope global | awk "/inet6/ {print \"ipv6 address: \" \$2; exit}"
echo "OK: ipv6"

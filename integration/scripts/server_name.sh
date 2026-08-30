#!/bin/bash
# An explicit server_name reaches the Droplet unchanged. DigitalOcean uses the
# Droplet name as the hostname, so the Droplet can check this itself.
#
# Usage: server_name.sh <expected name>
set -euo pipefail
expected="${1:?usage: server_name.sh <expected name>}"

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

echo "== server_name =="

name="$(metadata hostname)"
echo "metadata hostname: ${name}"
[ "${name}" = "${expected}" ] || fail "expected the Droplet to be named '${expected}', got '${name}'"

echo "OK: server_name"

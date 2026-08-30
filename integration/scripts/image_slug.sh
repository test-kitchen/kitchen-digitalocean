#!/bin/bash
# An unmapped platform name has to reach the API as a slug, untouched. The
# platform here is debian-13-x64, which is deliberately not in
# PLATFORM_SLUG_MAP, so this passes only if the pass-through in #default_image
# works and the slug is one DigitalOcean still offers.
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

echo "== image slug pass-through =="
cat /etc/os-release

grep -q "^ID=debian" /etc/os-release || fail "expected a Debian image"
grep -q "^VERSION_ID=\"13\"" /etc/os-release || fail "expected Debian 13"

echo "OK: image slug pass-through"

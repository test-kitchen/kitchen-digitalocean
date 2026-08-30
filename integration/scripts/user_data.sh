#!/bin/bash
# user_data reached cloud-init verbatim and ran.
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

echo "== user_data =="
metadata user-data || fail "the metadata service returned no user data"

if ! retry 30 test -f /etc/kitchen-user-data; then
  echo "cloud-init output:" >&2
  tail -30 /var/log/cloud-init-output.log >&2 || true
  fail "user_data did not run"
fi

cat /etc/kitchen-user-data
echo "OK: user_data"

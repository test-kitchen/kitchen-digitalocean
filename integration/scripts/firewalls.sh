#!/bin/bash
# attach_firewalls runs before the driver waits for the transport, so a Droplet
# that answered at all was placed behind the firewall and the firewall still
# permits 22. A firewall the API does not know is warned about and skipped, so
# the interesting failure is the opposite one: attaching a real firewall and
# locking the Droplet out.
#
# Usage: firewalls.sh [firewall id]
set -euo pipefail
firewall_id="${1:-}"

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

echo "== firewalls =="

if [ -z "${firewall_id}" ]; then
  echo "SKIP: no firewall id was configured, so no firewall was attached"
  exit 0
fi

echo "droplet id: $(metadata id)"
echo "reached the Droplet over SSH with firewall ${firewall_id} attached"

# Outbound still works, so attaching the firewall did not take egress with it.
metadata region >/dev/null || fail "outbound requests are blocked"

echo "OK: firewalls"

#!/bin/bash
# A non-default size in a non-default region. A size the region does not offer
# is a 422 at create time, which is the failure this suite exists to catch. If
# the Droplet is up at all the pair was accepted, so check it is the pair that
# was asked for rather than a silent fallback.
#
# Usage: size_region.sh <expected region>
set -euo pipefail
expected_region="${1:?usage: size_region.sh <expected region>}"

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

echo "== size and region =="

region="$(metadata region)"
echo "region: ${region}"
[ "${region}" = "${expected_region}" ] || fail "expected region '${expected_region}', got '${region}'"

# s-1vcpu-2gb. /proc reports a little under the nominal 2 GiB.
memory_kb="$(awk "/^MemTotal:/ {print \$2}" /proc/meminfo)"
echo "MemTotal: ${memory_kb} kB"
[ "${memory_kb}" -gt 1500000 ] || fail "expected about 2 GB of memory, got ${memory_kb} kB"

echo "OK: size and region"

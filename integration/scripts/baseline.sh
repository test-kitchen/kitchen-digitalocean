#!/bin/bash
# The Droplet exists, is reachable over the driver's own transport, and the
# metadata service agrees with what the driver was asked for.
#
# Usage: baseline.sh <expected region>
set -euo pipefail
expected_region="${1:?usage: baseline.sh <expected region>}"

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

echo "== baseline =="
uname -a
cat /etc/os-release

# The shell provisioner runs under sudo, so check who logged in rather than who
# is executing. The driver defaults username to root.
login_user="${SUDO_USER:-$(whoami)}"
echo "login user: ${login_user}"
[ "${login_user}" = "root" ] || fail "expected to log in as 'root', got '${login_user}'"

droplet_id="$(metadata id)" || fail "the metadata service did not answer"
echo "droplet id: ${droplet_id}"
[ -n "${droplet_id}" ] || fail "the metadata service reported no droplet id"

region="$(metadata region)"
echo "region: ${region}"
[ "${region}" = "${expected_region}" ] || fail "expected region '${expected_region}', got '${region}'"

# The platform is ubuntu-24, a short name PLATFORM_SLUG_MAP has to resolve to
# ubuntu-24-04-x64. Nothing but the catalogue can confirm that mapping.
grep -q "^ID=ubuntu" /etc/os-release || fail "expected an Ubuntu image"
grep -q "^VERSION_ID=\"24.04\"" /etc/os-release || fail "expected Ubuntu 24.04"

# default_name budgets 63 octets so the name fits one DNS label, and strips
# everything DigitalOcean rejects in a Droplet name.
host="$(hostname)"
echo "hostname: ${host}"
[ "${#host}" -le 63 ] || fail "hostname '${host}' is longer than 63 characters"
[[ "${host}" =~ ^[A-Za-z0-9.-]+$ ]] || fail "hostname '${host}' has characters DigitalOcean rejects"

echo "OK: baseline"

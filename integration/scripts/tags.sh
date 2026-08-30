#!/bin/bash
# tags reach the Droplet, whether they were written as a YAML list or as the
# delimited string kitchen.yml tends to produce. normalize_list splits the
# string; only the API can confirm both halves arrived as separate tags rather
# than as one tag with a comma in it.
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

echo "== tags =="

# Both checks below match the tag whole. That is what catches an unsplit list:
# a `tags: "a, b"` sent verbatim arrives as the single tag `a, b`, which
# matches neither `a` nor `b` exactly.
tags="$(metadata tags || true)"

if [ -n "${tags}" ]; then
  echo "tags:"
  echo "${tags}"
  for expected in kitchen-tag-one kitchen-tag-two; do
    grep -qx "${expected}" <<<"${tags}" || fail "tag '${expected}' was not applied"
  done
else
  # Older metadata builds do not serve /tags on its own.
  json="$(metadata_json)" || fail "the metadata service did not answer"
  echo "metadata: ${json}"
  for expected in kitchen-tag-one kitchen-tag-two; do
    grep -q "\"${expected}\"" <<<"${json}" || fail "tag '${expected}' was not applied"
  done
fi

echo "OK: tags"

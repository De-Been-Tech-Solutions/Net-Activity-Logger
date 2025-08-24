#!/usr/bin/env bash
# net_log.sh - Generic network throughput + peer logger
#
# Usage:
#   ./net_log.sh <iface> [interval_seconds] [process_filter]
# Examples:
#   ./net_log.sh wlp4s0 1 steam        # Only Steam processes
#   ./net_log.sh wlp4s0 1 xivlauncher  # XIVLauncher / FFXIV
#   ./net_log.sh wlp4s0 1 all          # All established connections
#
# Output: CSV -> timestamp,iface,mb_per_s,peers

IFACE="$1"
INTERVAL="${2:-1}"
FILTER="${3:-steam}"   # Default: steam

if [[ -z "$IFACE" ]]; then
  echo "Usage: $0 <iface> [interval] [process_filter]" >&2
  exit 1
fi

# Find RX bytes for iface
get_rx_bytes() {
  awk -v ifc="$IFACE" -F'[: ]+' '$1==ifc{print $3}' /proc/net/dev
}

# CSV header
echo "timestamp,iface,mb_per_s,peers"

prev=$(get_rx_bytes)
prev_ts=$(date +%s)

while :; do
  sleep "$INTERVAL"
  now=$(date +%s)
  cur=$(get_rx_bytes)

  delta_bytes=$((cur - prev))
  elapsed=$((now - prev_ts))
  if (( elapsed < 1 )); then elapsed=1; fi
  mbps=$(awk -v b="$delta_bytes" -v e="$elapsed" 'BEGIN{printf "%.2f", (b/e)/1000000}')

  # Grab peers
  if [[ "$FILTER" == "all" ]]; then
    peers=$(ss -tupn 2>/dev/null | awk '/ESTAB/ {print $5}' \
            | sed 's/^\[//; s/\]//;' | sort -u | tr '\n' ' ')
  else
    peers=$(ss -tupn 2>/dev/null | awk -v f="$FILTER" '$0 ~ f && /ESTAB/ {print $5}' \
            | sed 's/^\[//; s/\]//;' | sort -u | tr '\n' ' ')
  fi

  ts=$(date -Iseconds)
  echo "$ts,$IFACE,$mbps,\"$peers\""

  prev="$cur"
  prev_ts="$now"
done


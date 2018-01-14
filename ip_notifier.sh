#!/bin/sh
set -e

prev=""

if [ -z "$INTERFACES" ]; then
  INTERFACES="eth0 wlan0"
fi

get_ip_address() {
  ifconfig "$1" 2>/dev/null | sed -nE 's/\s+inet addr:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) .*$/\1/p' || :
}

get_ip6_address() {
  ifconfig "$1" 2>/dev/null | sed -nE 's/\s+inet6 addr: ([0-9a-f:]+)\/\d+ .*$/\1/p' || :
}

get_ip_addresses() {
  for interface in $INTERFACES; do
    get_ip_address "$interface"
  done
  for interface in $INTERFACES; do
    get_ip6_address "$interface"
  done
}

send_to_slack() {
  curl -X POST --data-urlencode 'payload={"text":"local IP address has changed:\n```\n'"$1"'\n```"}' "$2"
}

while true; do
  addresses="$(get_ip_addresses)"
  if [ "$prev" != "$addresses" ]; then
    echo "changed:"
    echo "$addresses"

    if [ -n "$WEBHOOK_URL" ] && [ "$addresses" != "" ]; then
      echo "Sending to slack..."
      send_to_slack "$addresses" "$WEBHOOK_URL" && echo
    fi
  fi
  prev="$addresses"
  sleep 10
done

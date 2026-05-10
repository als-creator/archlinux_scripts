#!/bin/bash
set -euo pipefail

URL="https://raw.githubusercontent.com/yggdrasil-network/public-peers/refs/heads/master/europe/russia.md"

sudo pacman -S --noconfirm yggdrasil
yggdrasil -genconf | sudo tee /etc/yggdrasil.conf > /dev/null

PEERS=$(curl -sL "$URL" \
  | grep -Eo '(tcp|tls|quic|ws|wss|socks)://[^[:space:]"'\''<>`|*]+' \
  | awk '{print "  \""$0"\","}')

if [ -z "${PEERS:-}" ]; then
  exit 1
fi

sudo awk -v p="$PEERS" '
/^[[:space:]]*Peers:[[:space:]]*\[.*\]/ {
  sub(/\[.*\]/, "[\n" p "\n]")
  print
  next
}
/^[[:space:]]*Peers:[[:space:]]*\[/ {
  print
  print p
  in_peers = 1
  next
}
in_peers {
  if (/\]/) {
    print
    in_peers = 0
  }
  next
}
{ print }
' /etc/yggdrasil.conf > /tmp/yggdrasil.conf.tmp

sudo mv /tmp/yggdrasil.conf.tmp /etc/yggdrasil.conf
sudo systemctl enable --now yggdrasil
sudo systemctl status yggdrasil
exit 0

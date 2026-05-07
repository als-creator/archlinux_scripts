#!/bin/bash
set -euo pipefail

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "Не запускайте скрипт от root." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo не установлен, установите его." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git не установлен, установите его." >&2
  exit 1
fi

if ! command -v makepkg >/dev/null 2>&1; then
  echo "makepkg не найден, установите base-devel." >&2
  exit 1
fi

if ! command -v yay >/dev/null 2>&1; then
  echo "yay не найден — собираю из AUR..."
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  cd "$tmpdir"
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
fi

echo "yay собран, установлен и готов к использованию"

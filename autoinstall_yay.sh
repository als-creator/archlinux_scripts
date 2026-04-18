# Автосборка и установка yay из aur
#!/bin/bash
set -euo pipefail

# Запрещаем запуск от root
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "Не запускайте скрипт от root." >&2
  exit 1
fi

# Проверка наличия sudo
if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo не установлен, установите его." >&2
  exit 1
fi

# Установка yay из AUR, если не найден
if ! command -v yay >/dev/null 2>&1; then
  echo "yay не найден — собираю из AUR..."
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  cd "$tmpdir"
  git clone https://aur.archlinux.org/yay.git
  cd yay
  # makepkg требует прав пользователя (не root). makepkg -si попытается установить пакеты через pacman; если нужна интерактивность --noconfirm используется.
  makepkg -si --noconfirm
  cd -
fi

echo "yay успешно собран и установлен"
exit 0

#!/bin/bash

echo "========================================"
echo "Установка SDDM в ArchLinux и настройка темы Sugar Candy"
echo "========================================"

# Проверка и установка SDDM
if ! pacman -Q sddm &>/dev/null; then
    echo "SDDM не установлен. Устанавливаем..."
    sudo pacman -Sy --noconfirm sddm
else
    echo "SDDM уже установлен."
fi

# Отключение другого дисплейного менеджера и включение SDDM
echo "Отключаем текущий display manager (если установлен)..."
sudo systemctl disable display-manager

echo "Включаем SDDM..."
sudo systemctl enable sddm

# Установка темы Sugar Candy через yay (AUR helper)
if ! yay -Q sddm-sugar-candy-git &>/dev/null; then
    echo "Устанавливаем тему sddm-sugar-candy-git через yay..."
    yay -S --noconfirm sddm-sugar-candy-git
else
    echo "Тема sddm-sugar-candy-git уже установлена."
fi

# Проверяем наличие темы
THEME_PATH="/usr/share/sddm/themes/sugar-candy"
if [ -d "$THEME_PATH" ]; then
    echo "Тема sugar-candy обнаружена!"
else
    echo "Тема sugar-candy не найдена. Проверьте установку."
    exit 1
fi

# Настройка темы в конфиге sddm
SDDM_CONF="/etc/sddm.conf"
echo "Настраиваем тему SDDM..."
if [ ! -f "$SDDM_CONF" ]; then
    echo "Создаем новый /etc/sddm.conf"
    sudo touch "$SDDM_CONF"
fi

sudo sed -i '/^$$Theme$$/d' "$SDDM_CONF"
sudo sed -i '/^Current=/d' "$SDDM_CONF"
echo -e "[Theme]\nCurrent=sugar-candy" | sudo tee -a "$SDDM_CONF" > /dev/null

echo "========================================"
echo "SDDM установлен и настроен с темой Sugar Candy."
echo "ПЕРЕЗАГРУЗИТЕ компьютер для применения изменений."
echo "Список тем:"
ls /usr/share/sddm/themes/
echo "========================================"

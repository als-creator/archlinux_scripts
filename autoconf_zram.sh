#!/bin/bash

echo "========================================"
echo "Установка и настройка zram-generator"
echo "========================================"

# Установка zram-generator
echo "Устанавливаем zram-generator..."
sudo pacman -Sy --noconfirm zram-generator

# Создание конфигурационного файла
echo "Настраиваем /etc/systemd/zram-generator.conf..."
sudo bash -c 'cat > /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF'

# Перезапуск systemd и активация zram
echo "Перезапускаем systemd (daemon-reload)..."
sudo systemctl daemon-reload

echo "Запускаем zram..."
sudo systemctl start /dev/zram0

echo "========================================"
echo "zram-generator установлен и настроен!"
echo ""
echo "Для проверки после ребута используйте команды:"
echo "  zramctl"
echo "  swapon"
echo ""
echo "zram-generator будет запускаться автоматически при загрузке системы."
echo "========================================"

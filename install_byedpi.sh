# Короткая версия для настройки byedpi без проверок
#!/bin/bash
set -e
# Установка пакета
yay -Sy --noconfirm byedpi-bin

# Запись настроек в конфиг-файл
echo 'BYEDPI_OPTIONS="-i 127.0.0.1 --port 14228 -d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -r1+s -S -a1 -As -d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -S -a1"' | sudo tee /etc/byedpi.conf > /dev/null

# Включение и запуск сервиса
sudo systemctl enable --now byedpi
sudo systemctl restart byedpi

echo "ByeDPI установлен и запущен"
echo "sudo systemctl restart byedpi для перезапуска"
echo "sudo systemctl start byedpi для запуска"
echo "sudo systemctl status byedpi для проверки статуса сервиса"
sudo systemctl status byedpi

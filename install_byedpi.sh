# Короткая версия для настройки byedpi без проверок
#!/bin/bash
set -e
# Установка пакета
yay -Sy --noconfirm byedpi-bin

# Запись настроек в конфиг-файл
echo 'BYEDPI_OPTIONS="-i 127.0.0.1 --port 14228 -Kt,h -s0 -o1 -Ar -o1 -At -f-1 --md5sig -r1+s -As,n -Ku -a5 -An"' | sudo tee /etc/byedpi.conf > /dev/null

# Включение и запуск сервиса
sudo systemctl enable --now byedpi
sudo systemctl restart byedpi

echo "ByeDPI установлен и запущен"
echo "sudo systemctl restart byedpi для перезапуска"
echo "sudo systemctl start byedpi для запуска"
echo "sudo systemctl status byedpi для проверки статуса сервиса"
sudo systemctl status byedpi

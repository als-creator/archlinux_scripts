# Скрипт для автонастройки byedpi на archlinux, поднимает службу с одним правилом, настроить порт и правило можно через /etc/byedpi.conf
#!/bin/bash
set -e

# Запрещаем запуск от root
[ "$EUID" -eq 0 ] && { echo "Не запускайте скрипт от root." >&2; exit 1; }

# Проверка наличия sudo
if sudo -l &>/dev/null; then
  echo "Есть права sudo"
else
  echo "Нет прав sudo"
  exit 1
fi

# Установка yay из AUR вручную, если не найден
command -v yay &>/dev/null \
  || {
    echo "yay не найден — собираю из AUR..."
    cd /tmp
    [ -d yay ] && rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
  }

# Установка byedpi-bin, если его нет
pacman -Q byedpi-bin &>/dev/null \
  || yay -Sy --noconfirm byedpi-bin

# Конфиг byedpi
echo 'BYEDPI_OPTIONS="-i 127.0.0.1 --port 14228 -d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -r1+s -S -a1 -As -d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -S -a1"' \
  | sudo tee /etc/byedpi.conf > /dev/null

# Включение и запуск byedpi
sudo systemctl enable --now byedpi

echo "ByeDPI успешно установлен и запущен на адресе 127.0.0.1:14228"
echo "Правило и порт можно изменить в /etc/byedpi.conf"
echo "Для настройки прокси браузера можно использовать расширения FoxyProxy, SmartProxy или Proxy SwitchyOmega 3"
echo "Готовый бэкап настроек Proxy SwitchyOmega 3 для восстановления можно взять в репозитории скрипта"
echo "sudo systemctl restart byedpi для перезапуска"
echo "sudo systemctl start byedpi для запуска"
echo "sudo systemctl status byedpi для проверки статуса сервиса"
sudo systemctl status byedpi
exit

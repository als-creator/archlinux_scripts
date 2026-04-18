# Скрипт для автонастройки virtmanager на archlinux согласно wiki
#!/bin/bash

# Загрузка необходимых пакетов
echo "Установка пакетов virt-manager, libvirt, virt-viewer и других..."
sudo pacman -Syu --noconfirm virt-manager libvirt virt-viewer dnsmasq vde2 openbsd-netcat libguestfs

# Запуск и включение службы libvirtd
echo "Запуск и включение службы libvirtd..."
sudo systemctl enable --now libvirtd

# Изменение конфигурации libvirtd
echo "Настройка конфигурации libvirtd..."
sudo sed -i 's/^#unix_sock_group/unix_sock_group/' /etc/libvirt/libvirtd.conf
sudo sed -i 's/^#unix_sock_rw_perms/unix_sock_rw_perms/' /etc/libvirt/libvirtd.conf

# Установка прав unix_sock_rw_perms
sudo sed -i 's/^unix_sock_rw_perms = .*/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf

# Добавление пользователя в группу libvirt
USER=$(whoami)
echo "Добавление пользователя $USER в группу libvirt..."
sudo usermod -a -G libvirt $USER

# Перезапуск службы libvirtd
echo "Перезапуск службы libvirtd для применения изменений..."
sudo systemctl restart libvirtd

echo "Установка и настройка завершена. Пользователь $USER теперь имеет доступ к виртуальным машинам."

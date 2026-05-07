#!/bin/bash

echo ""
echo "================================================================================"
echo "Настройка Flatpak (добавление remote flathub и установка графического менеджера)"
echo "================================================================================"

# Проверяем, установлен ли flatpak
if ! pacman -Q flatpak &>/dev/null; then
    echo "flatpak не установлен. Устанавливаем flatpak..."
    sudo pacman -Sy --noconfirm flatpak
    if ! pacman -Q flatpak &>/dev/null; then
        echo "Не удалось установить flatpak. Проверьте подключение к интернету и права."
        exit 1
    fi
else
    echo "flatpak уже установлен."
fi

# Настройка remote flathub
if flatpak remote-list | grep -q flathub; then
    echo "Remote flathub уже существует."
else
    echo "Добавляем remote flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    if flatpak remote-list | grep -q flathub; then
        echo "Flatpak remote flathub успешно добавлен."
    else
        echo "Ошибка при добавлении remote flathub."
        exit 1
    fi
fi

# Установка графического менеджера GNOME Software
if ! command -v gnome-software &>/dev/null; then
    echo "Установка GNOME Software для управления приложениями..."
    sudo pacman -S --noconfirm gnome-software gnome-packagekit
    if ! command -v gnome-software &>/dev/null; then
        echo "Не удалось установить gnome-software. Проверьте репозитории."
        exit 1
    fi
else
    echo "GNOME Software уже установлен."
fi

# Запросите пользователя запустить GNOME Software вручную для первичной настройки
echo "Для начала работы откройте GNOME Software через меню приложений или команду: gnome-software"

# Проверка и добавление юзера к группе flatpak (по необходимости)
if ! groups | grep -q flatpak; then
    echo "Добавляем пользователя в группу flatpak..."
    sudo groupadd -f flatpak
    sudo usermod -aG flatpak $USER
    echo "Вам потребуется перезайти в систему, чтобы изменения вступили в силу."
fi

# Проверка, работает ли flatpak
echo "Проверка работоспособности flatpak..."
if flatpak --version &>/dev/null; then
    echo "Flatpak успешно настроен!"
else
    echo "Ошибка: Flatpak работает некорректно!"
    exit 1
fi

echo "================================================================================"
echo "Настройка завершена. Запустите GNOME Software для управления приложениями."
echo "================================================================================"

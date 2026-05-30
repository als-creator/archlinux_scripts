#!/bin/bash
# post-install.sh — пост-инсталляционные настройки для Arch Linux и Arch-based distros
# Пользователь: als
# Для использования нужно сменить все вхождения als в скрипте на своего пользователя
# На основе Arch Wiki:
# https://wiki.archlinux.org/title/General_recommendations
# https://wiki.archlinux.org/title/System_maintenance
# https://wiki.archlinux.org/title/Arch_User_Repository

set -euo pipefail

USERNAME="als"
DISTRO_NAME=$(awk -F= '$1=="NAME"{print $2}' /etc/os-release 2>/dev/null || echo "Arch Linux")

echo "==============================================================================="
echo "Пост-инсталляционный скрипт для $DISTRO_NAME"
echo "Пользователь: $USERNAME"
echo "==============================================================================="

# ================================================================================
# СОЗДАНИЕ ПОЛЬЗОВАТЕЛЯ ЕСЛИ ЕГО НЕТ
# ================================================================================
echo ""
echo "================================================================================"
echo "Создание пользователя $USERNAME (если не существует)"
echo "================================================================================"

if id "$USERNAME" &>/dev/null; then
    echo "Пользователь $USERNAME уже существует"
else
    echo "Создание пользователя $USERNAME..."
    sudo useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "Установите пароль пользователя $USERNAME:"
    sudo passwd "$USERNAME"
    echo "Пользователь $USERNAME создан"
fi

echo "Настройка sudo для группы wheel..."
sudo sed -i 's/^# %wheel/%wheel/g' /etc/sudoers

# ================================================================================
# Настройка локали (/etc/vconsole.conf)
# ================================================================================
echo ""
echo "================================================================================"
echo "Настройка локали (/etc/vconsole.conf): KEYMAP=ru, FONT=cyr-sun16"
echo "================================================================================"

echo "Запись KEYMAP=ru в /etc/vconsole.conf..."
echo "KEYMAP=ru" | sudo tee /etc/vconsole.conf

echo "Запись FONT=cyr-sun16 в /etc/vconsole.conf..."
echo "FONT=cyr-sun16" | sudo tee -a /etc/vconsole.conf

echo "/etc/vconsole.conf обновлён"
cat /etc/vconsole.conf

# ================================================================================
# Настройка монтирования дисков в /etc/fstab - LABEL=Data и LABEL=Work
# Еслиу вас нет таких дисков, то система не загрузится
# ================================================================================
echo ""
echo "================================================================================"
echo "Добавление в /etc/fstab дисков с LABEL=Data и LABEL=Work"
echo "================================================================================"

HOME_DIR=$(getent passwd "$USERNAME" | cut -d: -f6)

sudo mkdir -p "/run/media/${USERNAME}/Data"
sudo mkdir -p "/run/media/${USERNAME}/Work"

echo "Созданы точки монтирования:"
echo "/run/media/${USERNAME}/Data"
echo "/run/media/${USERNAME}/Work"

FSTAB_LINE1="LABEL=Data /run/media/${USERNAME}/Data auto nosuid,nodev,nofail,x-gvfs-show 0 0"
FSTAB_LINE2="LABEL=Work /run/media/${USERNAME}/Work auto nosuid,nodev,nofail,x-gvfs-show 0 0"

if grep -q "LABEL=Data" /etc/fstab; then
    echo "Строка LABEL=Data уже есть в /etc/fstab"
else
    echo "" | sudo tee -a /etc/fstab
    echo "$FSTAB_LINE1" | sudo tee -a /etc/fstab
    echo "Добавлено в /etc/fstab: $FSTAB_LINE1"
fi

if grep -q "LABEL=Work" /etc/fstab; then
    echo "Строка LABEL=Work уже есть в /etc/fstab"
else
    echo "$FSTAB_LINE2" | sudo tee -a /etc/fstab
    echo "Добавлено в /etc/fstab: $FSTAB_LINE2"
fi

echo ""
echo "Последние строки /etc/fstab:"
tail -5 /etc/fstab

# ================================================================================
# ПАРАЛЛЕЛЬНЫЕ ЗАГРУЗКИ В ПАКМАНЕ = 50
# ================================================================================
echo ""
echo "================================================================================"
echo "Установка ParallelDownloads = 50 в /etc/pacman.conf"
echo "================================================================================"

if grep -q "^ParallelDownloads" /etc/pacman.conf; then
    echo "ParallelDownloads уже установлен, меняем значение на 50..."
    sudo sed -i 's/^ParallelDownloads.*/ParallelDownloads = 50/' /etc/pacman.conf
else
    echo "Добавление ParallelDownloads = 50 в /etc/pacman.conf..."
    echo "ParallelDownloads = 50" | sudo tee -a /etc/pacman.conf
fi

echo "Текущее значение ParallelDownloads:"
grep "^ParallelDownloads" /etc/pacman.conf
echo "ParallelDownloads установлен на 50"

# ================================================================================
# Таймер PACCACHE (очистка кэша pacman по расписанию)
# ================================================================================
echo ""
echo "================================================================================"
echo "Настройка paccache.timer для автоматической очистки кэша pacman"
echo "================================================================================"

if ! sudo pacman -Q pacman-contrib &>/dev/null; then
    echo "Установка pacman-contrib (содержит paccache)..."
    sudo pacman -S --noconfirm pacman-contrib
fi

echo "Включение paccache.timer..."
sudo systemctl enable paccache.timer
echo "paccache.timer включён (очистка старых версий пакетов раз в 3 дня)"

# ================================================================================
# SSD TRIM (fstrim.timer)
# ================================================================================
echo ""
echo "================================================================================"
echo "Настройка TRIM для SSD (fstrim.timer)"
echo "================================================================================"

if [ -e /dev/nvme0n1 ] || [ -e /dev/sda ] || [ -e /dev/nvme0n1p1 ] || [ -e /dev/sda1 ]; then
    echo "Обнаружен SSD, включение fstrim.timer..."
    sudo systemctl enable fstrim.timer
    echo "fstrim.timer включён (раз в неделю)"
else
    echo "SSD не обнаружен, fstrim.timer пропущен"
fi

# ================================================================================
# ДОБАВЛЕНИЕ КИТАЙСКОЙ РЕПЫ [archlinuxcn]
# ================================================================================
echo ""
echo "================================================================================"
echo "Добавление репозитория archlinuxcn в /etc/pacman.conf"
echo "================================================================================"

if grep -q "\[archlinuxcn\]" /etc/pacman.conf; then
    echo "Репозиторий [archlinuxcn] уже существует в /etc/pacman.conf"
else
    echo "Добавление [archlinuxcn] в конец /etc/pacman.conf..."
    echo "" | sudo tee -a /etc/pacman.conf
    echo "[archlinuxcn]" | sudo tee -a /etc/pacman.conf
    echo "Server = https://repo.archlinuxcn.org/\$arch" | sudo tee -a /etc/pacman.conf
    echo "Репозиторий [archlinuxcn] добавлен"
fi

echo "Установка archlinuxcn-keyring для подписи пакетов из репозитория archlinuxcn"
sudo pacman -Sy archlinuxcn-keyring --noconfirm

# ================================================================================
# ВЫБОР БЫСТРЫХ ЗЕРКАЛ ЧЕРЕЗ REFLECTOR
# ================================================================================
echo ""
echo "================================================================================"
echo "Обновление mirrorlist через reflector (Россия, HTTPS, по скорости)"
echo "================================================================================"

if ! sudo pacman -Q reflector &>/dev/null; then
    echo "Установка reflector..."
    sudo pacman -S reflector --noconfirm
fi

echo "Запуск reflector для выбора быстрых зеркал (Россия, возраст 12 часов, HTTPS)..."
sudo reflector --country Russia --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo "Mirrorlist обновлён: /etc/pacman.d/mirrorlist"

# Небольшое обновление после смены зеркал
echo "Краткое обновление базы пакетов после смены зеркал..."
sudo pacman -Sy --noconfirm

# ================================================================================
# СБОРКА AUR HELPER (yay) ЕСЛИ ЕГО НЕТ
# ================================================================================
echo ""
echo "================================================================================"
echo "Проверяем и устанавливаем AUR helper (yay) если отсутствует"
echo "================================================================================"

if sudo pacman -Q yay &>/dev/null; then
    echo "yay уже установлен"
else
    echo "Установка base-devel и git для сборки yay..."
    sudo pacman -S --noconfirm git base-devel

    echo "Клонирование репозитория yay из AUR..."
    tmpdir=$(mktemp -d)
    cd "$tmpdir"
    git clone https://aur.archlinux.org/yay.git
    cd yay

    echo "Сборка и установка yay через makepkg..."
    makepkg -si --noconfirm

    cd ..
    rm -rf "$tmpdir"
    echo "yay установлен и готов к использованию"
fi

# ================================================================================
# УСТАНОВКА ОСНОВНЫХ ПАКЕТОВ
# ================================================================================
echo ""
echo "================================================================================"
echo "Установка основных пакетов через pacman -S"
echo "================================================================================"

PACKAGES=(
    base-devel
    hblock
    papirus-icon-theme
    obsidian-icon-theme
    gnome-software
    nftables
    fish
    xclip
    btop
    glances
    whois
    mtr
    traceroute
    reflector
    hwinfo
    hardinfo2
    qmmp
    smplayer
    smplayer-skins
    smplayer-themes
    neovim
    fastfetch
    guake
    vulkan-radeon
    vulkan-intel
    lib32-vulkan-radeon
    vulkan-tools
    mesa
    lib32-mesa
    libva-mesa-driver
    lib32-libva-mesa-driver
    micro
    ranger
    lf
    mc
    yazi
    galculator
    gnome-disk-utility
    kdiskmark
    baobab
    qbittorrent
    steam
    avidemux-qt
    handbrake
    foliate
    cron
    flameshot
    kdenlive
    kate
    konsole
    kdeconnect
    man-pages-ru
    nmap
    uv
    wireshark-qt
    filezilla
    putty
    xreader
    fd
    lsd
    ripgrep
    eza
    fzf
    zoxide
    bat
    thefuck
    direnv
    nikto
    aircrack-ng
    engrampa
    7zip
    github-cli
    viewnior
    rawtherapee
    lazygit
    lazydocker
    ttf-jetbrains-mono-nerd
    ttf-hack-nerd
    ttf-dejavu-nerd
    ttf-dejavu
    terminus-font
    noto-fonts
    ffmpegthumbnailer
    gvfs
    network-manager-applet
    xfce4-goodies
    thunar-vcs-plugin
    obsidian
    obs-studio
    flatpak
    zenmap
    aichat
    wgetpaste
    nvtop
    ddgr
    virtualbox
    docker-buildx
    docker
# aur пакеты
    thorium-browser-bin
    yandex-browser
    pyradio
    kora-icon-theme
    radiotray-ng
    anydesk-bin
    assistant
    rudesktop
    rustdesk
    qdiskinfo
    appimagelauncher
    localsend
)

echo "Установка ${#PACKAGES[@]} пакетов..."
yay -S --noconfirm "${PACKAGES[@]}"
echo "Все пакеты установлены"

# ================================================================================
# UACODE (процессорные микрокоды)
# ================================================================================
echo ""
echo "================================================================================"
echo "Установка микрокодов процессора Intel или AMD"
echo "================================================================================"

if grep -q "Intel" /proc/cpuinfo; then
    echo "Обнаружен процессор Intel, установка intel-ucode..."
    sudo pacman -S intel-ucode --noconfirm
    echo "Intel microcode установлен"
elif grep -q "AMD" /proc/cpuinfo; then
    echo "Обнаружен процессор AMD, установка amd-ucode..."
    sudo pacman -S amd-ucode --noconfirm
    echo "AMD microcode установлен"
else
    echo "Не удалось определить производителя процессора"
fi

# ================================================================================
# СМЕНА ОБОЛОЧКИ НА FISH
# ================================================================================
echo ""
echo "================================================================================"
echo "Смена оболочки пользователя $USERNAME на fish (/bin/fish)"
echo "================================================================================"
echo "fish уже установлен в пакетах, меняем шелл через chsh..."
sudo chsh -s /bin/fish "$USERNAME"
echo "В качестве оболочки пользователя $USERNAME используется /bin/fish"

# ================================================================================
# ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЯ В ГРУППЫ
# ================================================================================
echo ""
echo "================================================================================"
echo "Добавление пользователя $USERNAME в дополнительные группы"
echo "================================================================================"

echo "Добавление в группу docker..."
sudo usermod -aG docker "$USERNAME"

echo "Добавление в группу vboxusers..."
sudo usermod -aG vboxusers "$USERNAME"

echo "Добавление в группу network..."
sudo usermod -aG network "$USERNAME"

echo "Добавление в группу wheel..."
sudo usermod -aG wheel "$USERNAME"

echo ""
echo "Группы пользователя $USERNAME:"
id "$USERNAME"

echo ""
echo "==============================================================================="
echo "ВСЕ НАСТРОЙКИ ЗАВЕРШЕНЫ!"
echo "==============================================================================="
echo ""
echo "Что было сделано:"
echo "Пользователь $USERNAME создан (если не существовал), добавлен в группы"
echo "Добавлена китайская репа archlinuxcn, установлена оболочка fish для юзера"
echo "Настроен firewall, установлен набор необходимых пакетов"
echo "Настроена локаль, установлены коды для микропроцессоров"
echo "Запущены кое-какие сомнительные службы для оптимизации ОС"

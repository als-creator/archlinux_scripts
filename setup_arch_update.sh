#!/bin/bash
set -e

# Проверка, что запущено через sudo
if [ "$EUID" -ne 0 ]; then
    CURRENT_USER=$(whoami)
    echo "Текущий пользователь: $CURRENT_USER"
    echo "Требуются права root. Запустите с sudo."
    exec sudo CURRENT_USER="$CURRENT_USER" bash "$0" "$@"
fi

CURRENT_USER="${CURRENT_USER:-als}"
USER_HOME="/home/$CURRENT_USER"

# Проверка папки Desktop/Рабочий стол
if [ -d "$USER_HOME/Desktop" ]; then
    DESKTOP_DIR="$USER_HOME/Desktop"
elif [ -d "$USER_HOME/Рабочий стол" ]; then
    DESKTOP_DIR="$USER_HOME/Рабочий стол"
else
    echo "Ошибка: не найдена папка Desktop или Рабочий стол в $USER_HOME!"
    exit 1
fi

LOGFILE="$DESKTOP_DIR/arch_log.log"
TEMP_CRONFILE="/tmp/temp_crontab_$$.txt"

echo "Домашняя директория: $USER_HOME"
echo "Лог: $LOGFILE"

# Права лог-файла
touch "$LOGFILE"
chmod 666 "$LOGFILE"

# Cron задания
CRON_DAILY_UPDATE="0 12 * * * root yay -Syu --noconfirm >> \"$LOGFILE\" 2>&1"
CRON_NIGHTLY_UPDATE="0 22 * * * root yay -Syu --noconfirm >> \"$LOGFILE\" 2>&1"
CRON_CLEAN_CACHE="30 11 * * 6 root pacman -Scc --noconfirm && flatpak uninstall --unused -y && journalctl --vacuum-time=1w >> \"$LOGFILE\" 2>&1"

# Создать временный файл
{
    echo "$CRON_DAILY_UPDATE"
    echo "$CRON_NIGHTLY_UPDATE"
    echo "$CRON_CLEAN_CACHE"
} > "$TEMP_CRONFILE"

echo "Cron задания:"
cat "$TEMP_CRONFILE"

# Запись в /etc/crontab
echo "Обновляем /etc/crontab..." | tee -a "$LOGFILE"
cat "$TEMP_CRONFILE" >> /etc/crontab
rm -f "$TEMP_CRONFILE"
cat /etc/crontab
echo "Готово! Правила добавлены." | tee -a "$LOGFILE"
echo "Расписание:" | tee -a "$LOGFILE"
echo "в 12:00 каждый день - yay -Syu --noconfirm" | tee -a "$LOGFILE"
echo "в 22:00 каждый день - yay -Syu --noconfirm" | tee -a "$LOGFILE"
echo "в субботу в 11:30 - очистка"

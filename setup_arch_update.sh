#!/bin/bash
set -e

# Проверка, что запущено через sudo
if [ "$EUID" -ne 0 ]; then
    CURRENT_USER=$(whoami)
    echo "Текущий пользователь: $CURRENT_USER"
    echo "Нужен root. Запустите с sudo."
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
    echo "Ошибка: не найдена папка Desktop или Рабочий стол в $USER_HOME!" | tee -a /tmp/arch_setup.log
    exit 1
fi

LOGFILE="$DESKTOP_DIR/arch_log.log"
TEMP_CRONFILE="/tmp/temp_crontab_$$.txt"

echo "Домашняя директория: $USER_HOME"
echo "Лог будет выводиться в файл $LOGFILE"

# Создание лог‑файла с правильными правами
touch "$LOGFILE"
chown "$CURRENT_USER:$CURRENT_USER" "$LOGFILE"  # Устанавливаем владельца — обычного пользователя
chmod 664 "$LOGFILE"

# Активация и проверка cronie
echo "Проверяем и настраиваем cronie..." | tee -a "$LOGFILE"

# Проверяем, установлен ли cronie
if ! pacman -Q cronie &> /dev/null; then
    echo "cronie не установлен. Устанавливаем..." | tee -a "$LOGFILE"
    pacman -S --noconfirm cronie
fi

# Запускаем и включаем cronie
if systemctl is-active --quiet cronie; then
    echo "cronie уже запущен." | tee -a "$LOGFILE"
else
    echo "Запускаем cronie..." | tee -a "$LOGFILE"
    systemctl start cronie
fi

if systemctl is-enabled --quiet cronie; then
    echo "cronie настроен на автозапуск." | tee -a "$LOGFILE"
else
    echo "Включаем автозапуск cronie..." | tee -a "$LOGFILE"
    systemctl enable --now cronie
fi

# Проверяем статус cronie
if systemctl is-active --quiet cronie; then
    echo "cronie успешно запущен и работает." | tee -a "$LOGFILE"
else
    echo "Ошибка: cronie не удалось запустить. Проверьте установку и конфигурацию." | tee -a "$LOGFILE"
    exit 1
fi

# Cron‑задания (используем pacman, как в исходном cron)
CRON_DAILY_UPDATE="0 12 * * * root pacman -Syu --noconfirm >> \"$LOGFILE\" 2>&1"
CRON_NIGHTLY_UPDATE="0 22 * * * root pacman -Syu --noconfirm >> \"$LOGFILE\" 2>&1"
CRON_CLEAN_CACHE="30 11 * * 6 root pacman -Scc --noconfirm && flatpak uninstall --unused -y && journalctl --vacuum-time=1w >> \"$LOGFILE\" 2>&1"

# Проверяем существование заданий в /etc/crontab
check_cron_exists() {
    local cron_entry="$1"
    grep -F -q "$cron_entry" /etc/crontab 2>/dev/null
}

# Создаём временный файл только с новыми заданиями
{
    if ! check_cron_exists "$CRON_DAILY_UPDATE"; then
        echo "$CRON_DAILY_UPDATE"
    fi
    if ! check_cron_exists "$CRON_NIGHTLY_UPDATE"; then
        echo "$CRON_NIGHTLY_UPDATE"
    fi
    if ! check_cron_exists "$CRON_CLEAN_CACHE"; then
        echo "$CRON_CLEAN_CACHE"
    fi
} > "$TEMP_CRONFILE"

# Если временный файл пустой — все задания уже есть
if [ ! -s "$TEMP_CRONFILE" ]; then
    echo "Все cron‑задания уже присутствуют в /etc/crontab" | tee -a "$LOGFILE"
    rm -f "$TEMP_CRONFILE"
    exit 0
fi

echo "Cron‑задания для добавления:" | tee -a "$LOGFILE"
cat "$TEMP_CRONFILE" | tee -a "$LOGFILE"

# Запись в /etc/crontab с проверкой прав
echo "Обновляем /etc/crontab..." | tee -a "$LOGFILE"
if cat "$TEMP_CRONFILE" >> /etc/crontab; then
    echo "Cron‑задания успешно добавлены в /etc/crontab." | tee -a "$LOGFILE"
else
    echo "Ошибка: не удалось записать в /etc/crontab. Проверьте права доступа." | tee -a "$LOGFILE"
    rm -f "$TEMP_CRONFILE"
    exit 1
fi

rm -f "$TEMP_CRONFILE"

echo "Готово! Теперь система будет обновляться в фоне из официальных реп каждый день в 12:00 и в 22:00 + очистка системы по субботам в 11:30 с выводом лога на рабочий стол" | tee -a "$LOGFILE"

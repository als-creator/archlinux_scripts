# Добавление фонового автообновления по крону в 12.00 + 22.00 + автоочистка в фоне по субботам в 11.30
#!/bin/bash

LOGFILE="/home/als/Рабочий стол/arch_log.log"

# Первая строка для обновления в 12:00
CRON_DAILY_UPDATE='0 12 * * * root /usr/bin/pacman -Syu --noconfirm >> "/home/als/Рабочий стол/arch_log.log" 2>&1'

# Вторая строка для обновления в 22:00
CRON_NIGHTLY_UPDATE='0 22 * * * root /usr/bin/pacman -Syu --noconfirm >> "/home/als/Рабочий стол/arch_log.log" 2>&1'

# Очистка кэша пакетов по субботам в 11.30
CRON_CLEAN_CACHE='30 11 * * 6 root /usr/bin/pacman -Sc --noconfirm >> "/home/als/Рабочий стол/arch_log.log" 2>&1'

# Установка cronie
echo "Устанавливаем cronie..." | tee -a "$LOGFILE"
sudo pacman -Sy --noconfirm cronie >> "$LOGFILE" 2>&1

# Активация и запуск cronie
echo "Включаем и запускаем cronie.service..." | tee -a "$LOGFILE"
sudo systemctl enable --now cronie.service >> "$LOGFILE" 2>&1

# Проверка и добавление первого задания (12:00)
echo "Проверяем наличие правила для дневного обновления в /etc/crontab..." | tee -a "$LOGFILE"
if ! sudo grep -Fq "$CRON_DAILY_UPDATE" /etc/crontab; then
    echo "Добавляем правило для дневного обновления в /etc/crontab..." | tee -a "$LOGFILE"
    echo "$CRON_DAILY_UPDATE" | sudo tee -a /etc/crontab > /dev/null
else
    echo "Правило для дневного обновления уже присутствует." | tee -a "$LOGFILE"
fi

# Проверка и добавление второго задания (22:00)
echo "Проверяем наличие правила для вечернего обновления в /etc/crontab..." | tee -a "$LOGFILE"
if ! sudo grep -Fq "$CRON_NIGHTLY_UPDATE" /etc/crontab; then
    echo "Добавляем правило для вечернего обновления в /etc/crontab..." | tee -a "$LOGFILE"
    echo "$CRON_NIGHTLY_UPDATE" | sudo tee -a /etc/crontab > /dev/null
else
    echo "Правило для вечернего обновления уже присутствует." | tee -a "$LOGFILE"
fi

# Проверка и добавление очистки кэша
echo "Проверяем наличие правила для еженедельной очистки кэша /etc/crontab..." | tee -a "$LOGFILE"
if ! sudo grep -Fq "$CRON_CLEAN_CACHE" /etc/crontab; then
    echo "Добавляем правило для еженедельной очистки кэша /etc/crontab..." | tee -a "$LOGFILE"
    echo "$CRON_CLEAN_CACHE" | sudo tee -a /etc/crontab > /dev/null
else
    echo "Правило для еженедельной очистки кэша /etc/crontab уже присутствует." | tee -a "$LOGFILE"
fi

echo "Готово! Правила добавлены в системный crontab" | tee -a "$LOGFILE"

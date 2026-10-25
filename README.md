# archlinux_scripts

archlinux_postinstall_script.sh  
Создание пользователя, добавление в необходимые группы, добавление дополнительных реп, установка набора пакетов, сомнительные оптимизации имени меня.

autoinstall_byedpi_archlinux.sh  
Установщик byedpi: пакет `byedpi-bin` из AUR. По умолчанию — режим без расширения (ipset): весь TCP 80/443 идёт через ByeDPI с фильтром по SNI, браузер настраивать не нужно. Конфиг в `/etc/byedpi/{conf,hosts,rule,port}`, блокировка QUIC.  
`--extension` — socks5 127.0.0.1:14228 для расширения браузера. `--off` удаляет сервисы, правила iptables, конфиги и сам пакет (`--keep-package` оставит пакет).  

autoinstall_virtmanager_archinstall.sh  
Настраивает virtmanager по archwiki  

autoinstall_zapret_archlinux.sh  
Автонастройка zapret на archlinux с конфигом и доменами + сборка yay из git если не хватает  

install_byedpi.sh  
Элементарный конфиг настройки byedpi без проверок совместимости, MVP  

setup_arch_update.sh  
Добавление фонового автообновления в системный crontab в 12.00 + 22.00 + автоочистка в фоне по субботам в 11.30  

setup_conky.sh  
Конфиг коньков, одна из версий, актуальный конфиг со скрином и автонастройкой есть в отдельной репе  
Нужно править имя сетевой карты из ip a, диски и город для погоды  

autoinstall_yay_archlinux.sh  
Автосборка и установка yay из aur  

autoconf_flatpak.sh  
Настройка flatpak + магазина приложений gnome-software

autoconf_zram.sh  
Автонастройка zram размером в половину ОЗУ

autoconf_sddm.sh  
Автонастройка sddm + тема sugar-candy

autoconf_yggdrasil_archlinux.sh  
Автонастройка yggdrasil с российскими пирами

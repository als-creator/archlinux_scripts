# archlinux_scripts

autoinstall_byedpi_archlinux.sh  
Скрипт для автонастройки byedpi на archlinux, поднимает службу с одним пресетом, настроить порт и правило можно через /etc/byedpi.conf  
Адрес 127.0.0.1:14228 socks5, для настройки прокси браузера можно использовать расширения FoxyProxy, SmartProxy или Proxy SwitchyOmega 3  

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

autoinstall_yay.sh  
Автосборка и установка yay из aur  

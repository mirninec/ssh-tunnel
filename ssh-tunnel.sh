#!/bin/bash

# Параметры для SSH туннеля
SSH_PORT=2020
LOCAL_PORT=1080
REMOTE_USER=user
REMOTE_HOST=1.2.3.4
LOG_FILE="/var/log/ssh-tunnel.log"

# Функция для создания туннеля
create_tunnel() {
    ssh -p $SSH_PORT -f -C2qTnN -D $LOCAL_PORT $REMOTE_USER@$REMOTE_HOST
}

# Функция для логгирования
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Бесконечный цикл для поддержания соединения
while true; do
    # Проверка, активен ли туннель
    if ! ps aux | grep -q "[s]sh -p $SSH_PORT -f -C2qTnN -D $LOCAL_PORT $REMOTE_USER@$REMOTE_HOST"; then
        log "\x1b[31mТуннель разорван\x1b[m, восстанавливаем..."
        create_tunnel
        log "Туннель восстановлен."
    else
        log "\x1b[32mТуннель активен.\x1b[m"
    fi
    sleep 60 # Проверка каждые 60 секунд
done

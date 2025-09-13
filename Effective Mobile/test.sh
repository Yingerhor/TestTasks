#!/bin/bash

# Лог-файл
LOG_FILE="/var/log/monitoring.log"
# URL для мониторинга
MONITOR_URL="https://test.com/monitoring/test/api"
# Имя процесса
PROCESS_NAME="$(systemctl is-active monitor_test.timer)"
# Файл-флаг отметки последнего запуска таймера
LAST_STATE="$(cat /usr/local/bin/last_state_timestamp)"
LAST_STATE_FILE="/usr/local/bin/last_state_timestamp"

# Проверка перезапуска процесса
if [ "$(systemctl show --value -p ActiveEnterTimestampMonotonic monitor_test.timer)" != "$LAST_STATE" ]
then
    # Произошёл перезапуск процесса
    echo "$(date): Процесс перезапущен." >> "$LOG_FILE"
    echo "$(systemctl show --value -p ActiveEnterTimestampMonotonic monitor_test.timer)" > "$LAST_STATE_FILE"
fi

# Проверка, запущен ли процесс
if [ "$PROCESS_NAME" = "active" ]
then
    # Если процесс запущен, отправляем запрос
    if curl --silent --fail "$MONITOR_URL" > /dev/null
    then
        echo "$(date): Процесс запущен и успешно отправил запрос." >> "$LOG_FILE"
    else
        echo "$(date): Процесс запущен, но сервер мониторинга недоступен." >> "$LOG_FILE"
    fi
else
    # Если процесс не запущен, ничего не делаем
    exit 0
fi

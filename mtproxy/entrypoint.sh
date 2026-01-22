#!/bin/sh

# Проверяем наличие SECRET
if [ -z "$SECRET" ]; then
    echo "ERROR: SECRET environment variable is not set!"
    echo "Generate one with: head -c 16 /dev/urandom | xxd -ps"
    exit 1
fi

# Обновляем конфигурацию Telegram
echo "Updating Telegram config..."
curl -s https://core.telegram.org/getProxySecret -o /data/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o /data/proxy-multi.conf

# Логирование
echo "Starting MTProxy..."
echo "Secret: $SECRET"
echo "Port: ${PORT:-443}"

# Запускаем MTProxy
exec mtproto-proxy \
    -u nobody \
    -p ${PORT:-443} \
    -H ${PORT:-443} \
    -S $SECRET \
    --aes-pwd /data/proxy-secret /data/proxy-multi.conf \
    -M 1

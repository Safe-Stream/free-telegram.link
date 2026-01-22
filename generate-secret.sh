#!/bin/bash

# Скрипт генерации SECRET для MTProxy
# Запускать один раз при первой установке

echo "Генерация SECRET для MTProxy..."

# Генерация случайного секрета (32 байта в hex)
SECRET=$(head -c 16 /dev/urandom | xxd -ps)

echo ""
echo "======================================"
echo "СЕКРЕТ MTProxy сгенерирован:"
echo "SECRET: $SECRET"
echo "======================================"
echo ""

# Получаем IP сервера
SERVER_IP=$(curl -s ifconfig.me)

echo "IP сервера: $SERVER_IP"
echo ""

# Формируем ссылку для Telegram
TG_LINK="tg://proxy?server=$SERVER_IP&port=443&secret=$SECRET"
TG_LINK_T_ME="https://t.me/proxy?server=$SERVER_IP&port=443&secret=$SECRET"

echo "======================================"
echo "ССЫЛКИ ДЛЯ ПОДКЛЮЧЕНИЯ:"
echo ""
echo "Прямая ссылка:"
echo "$TG_LINK"
echo ""
echo "Универсальная ссылка:"
echo "$TG_LINK_T_ME"
echo "======================================"
echo ""

# Сохраняем в файл
cat > mtproxy-config.txt << EOF
MTProxy Configuration
=====================
SECRET: $SECRET
SERVER_IP: $SERVER_IP
PORT: 443

Telegram Links:
- Direct: $TG_LINK
- Universal: $TG_LINK_T_ME

Используйте эти данные для:
1. Замены <БУДЕТ_СГЕНЕРИРОВАН> в docker-compose.yml
2. Вставки ссылки в HTML-страницу
EOF

echo "Конфигурация сохранена в mtproxy-config.txt"
echo ""
echo "СЛЕДУЮЩИЕ ШАГИ:"
echo "1. Откройте docker-compose.yml"
echo "2. Замените <БУДЕТ_СГЕНЕРИРОВАН> на: $SECRET"
echo "3. Откройте nginx/html/index.html"
echo "4. Замените PROXY_LINK на одну из ссылок выше"

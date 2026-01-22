FROM alpine:latest

# Устанавливаем зависимости
RUN apk add --no-cache \
    build-base \
    linux-headers \
    openssl-dev \
    zlib-dev \
    git \
    curl

# Клонируем и собираем MTProxy
WORKDIR /tmp
RUN git clone https://github.com/TelegramMessenger/MTProxy.git && \
    cd MTProxy && \
    make && \
    cp objs/bin/mtproto-proxy /usr/local/bin/ && \
    cd / && \
    rm -rf /tmp/MTProxy

# Создаем рабочую директорию
WORKDIR /data

# Генерируем конфигурацию при запуске
RUN curl -s https://core.telegram.org/getProxySecret -o proxy-secret && \
    curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

# Порт
EXPOSE 443

# Скрипт запуска
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

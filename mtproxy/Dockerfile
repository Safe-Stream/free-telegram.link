FROM alpine:latest

# Устанавливаем зависимости для сборки и работы
RUN apk add --no-cache \
    build-base \
    gcc \
    g++ \
    make \
    linux-headers \
    openssl-dev \
    openssl-libs-static \
    zlib-dev \
    zlib-static \
    git \
    curl

# Клонируем и собираем MTProxy
WORKDIR /tmp
RUN git clone https://github.com/TelegramMessenger/MTProxy.git /tmp/MTProxy && \
    cd /tmp/MTProxy && \
    make && \
    cp objs/bin/mtproto-proxy /usr/local/bin/mtproto-proxy && \
    chmod +x /usr/local/bin/mtproto-proxy && \
    cd / && \
    rm -rf /tmp/MTProxy && \
    apk del build-base gcc g++ make git

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

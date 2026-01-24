FROM ubuntu:24.04

# Установка зависимостей
RUN apt-get update && \
    apt-get install -y git curl build-essential libssl-dev zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Сборка MTProxy
WORKDIR /opt
RUN git clone https://github.com/TelegramMessenger/MTProxy.git && \
    cd MTProxy && \
    make && \
    cp objs/bin/mtproto-proxy /usr/local/bin/

# Создание рабочей директории
RUN mkdir -p /opt/mtproxy

# Скачивание конфигов Telegram
RUN curl -s https://core.telegram.org/getProxySecret -o /opt/mtproxy/proxy-secret && \
    curl -s https://core.telegram.org/getProxyConfig -o /opt/mtproxy/proxy-multi.conf

WORKDIR /opt/mtproxy

# Точка входа
ENTRYPOINT ["/usr/local/bin/mtproto-proxy"]

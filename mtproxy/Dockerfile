FROM golang:1.21-alpine AS builder

# Устанавливаем git для клонирования
RUN apk add --no-cache git

# Клонируем и собираем MTG (MTProto Go)
WORKDIR /build
RUN git clone https://github.com/9seconds/mtg.git && \
    cd mtg && \
    go build -o mtg ./cmd/mtg

# Финальный образ
FROM alpine:latest

# Устанавливаем curl для скачивания конфигов
RUN apk add --no-cache curl bash

# Копируем бинарник из builder
COPY --from=builder /build/mtg/mtg /usr/local/bin/mtg
RUN chmod +x /usr/local/bin/mtg

# Создаем рабочую директорию
WORKDIR /data

# Порт
EXPOSE 443

# Скрипт запуска
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

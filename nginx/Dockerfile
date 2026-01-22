FROM nginx:alpine

# Установка дополнительных утилит
RUN apk add --no-cache curl

# Копируем конфигурацию nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Копируем статические файлы
COPY html /usr/share/nginx/html

# Создаем директории для логов
RUN mkdir -p /var/log/nginx

# Права доступа
RUN chmod -R 755 /usr/share/nginx/html

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

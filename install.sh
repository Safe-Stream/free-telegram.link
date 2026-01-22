#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Установка Telegram MTProxy + Веб-страница    ║${NC}"
echo -e "${BLUE}║    Из GitHub Container Registry (ghcr.io)     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Проверка root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Этот скрипт должен быть запущен с правами root${NC}" 
   exit 1
fi

# Проверка наличия репозитория
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Файл docker-compose.yml не найден${NC}"
    echo -e "${YELLOW}Сначала клонируйте репозиторий:${NC}"
    echo -e "${BLUE}git clone https://github.com/Safe-Stream/free-telegram.link.git${NC}"
    exit 1
fi

# Проверка Docker
echo -e "${YELLOW}🔍 Проверка Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker не установлен. Устанавливаю...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    echo -e "${GREEN}✓ Docker установлен${NC}"
else
    echo -e "${GREEN}✓ Docker уже установлен${NC}"
fi

# Проверка Docker Compose
echo -e "${YELLOW}🔍 Проверка Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Установка Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓ Docker Compose установлен${NC}"
else
    echo -e "${GREEN}✓ Docker Compose уже установлен${NC}"
fi

# Создание директорий
echo -e "${YELLOW}📁 Создание директорий...${NC}"
mkdir -p {config,certbot/conf,certbot/www,logs}

# Генерация SECRET
echo -e "${YELLOW}🔐 Генерация SECRET для MTProxy...${NC}"
SECRET=$(head -c 16 /dev/urandom | xxd -ps)
SERVER_IP=$(curl -s ifconfig.me)

echo -e "${GREEN}✓ SECRET сгенерирован: ${BLUE}$SECRET${NC}"
echo -e "${GREEN}✓ IP сервера: ${BLUE}$SERVER_IP${NC}"

# Формирование ссылок
TG_LINK="tg://proxy?server=$SERVER_IP&port=443&secret=$SECRET"
TG_LINK_T_ME="https://t.me/proxy?server=$SERVER_IP&port=443&secret=$SECRET"

# Копирование файлов
echo -e "${YELLOW}📋 Копирование конфигурационных файлов...${NC}"

# Создание .env файла
if [ ! -f ".env" ]; then
    cat > .env << EOF
MTPROXY_SECRET=$SECRET
LETSENCRYPT_EMAIL=$EMAIL
DOMAIN=free-telegram.link
SERVER_IP=$SERVER_IP
EOF
    echo -e "${GREEN}✓ Создан файл .env${NC}"
else
    # Обновляем существующий .env
    sed -i "s/MTPROXY_SECRET=.*/MTPROXY_SECRET=$SECRET/" .env
    sed -i "s/SERVER_IP=.*/SERVER_IP=$SERVER_IP/" .env
    echo -e "${GREEN}✓ Обновлен файл .env${NC}"
fi

# Сохранение конфигурации
cat > mtproxy-config.txt << EOF
MTProxy Configuration
=====================
SECRET: $SECRET
SERVER_IP: $SERVER_IP
PORT: 443

Telegram Links:
- Direct: $TG_LINK
- Universal: $TG_LINK_T_ME

Generated: $(date)
EOF

echo -e "${GREEN}✓ Конфигурация сохранена в mtproxy-config.txt${NC}"

# Получение SSL сертификата
echo -e "${YELLOW}🔒 Настройка SSL сертификата для free-telegram.link...${NC}"

if [ -z "$EMAIL" ]; then
    echo -e "${BLUE}Введите email для Let's Encrypt:${NC}"
    read -p "Email: " EMAIL
fi

# Создание базовой конфигурации nginx для ACME challenge
mkdir -p config
cat > config/nginx-temp.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name free-telegram.link www.free-telegram.link;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
    }
}
EOF

# Временный nginx для ACME challenge
docker run -d --name temp-nginx \
    -p 80:80 \
    -v $(pwd)/certbot/www:/var/www/certbot \
    -v $(pwd)/config/nginx-temp.conf:/etc/nginx/nginx.conf:ro \
    nginx:alpine

sleep 2

# Получение сертификата
docker run --rm \
    -v $(pwd)/certbot/conf:/etc/letsencrypt \
    -v $(pwd)/certbot/www:/var/www/certbot \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d free-telegram.link \
    -d www.free-telegram.link

# Остановка временного nginx
docker stop temp-nginx && docker rm temp-nginx

if [ -d "$(pwd)/certbot/conf/live/free-telegram.link" ]; then
    echo -e "${GREEN}✓ SSL сертификат успешно получен${NC}"
else
    echo -e "${RED}❌ Не удалось получить SSL сертификат${NC}"
    echo -e "${YELLOW}Проверьте, что домен free-telegram.link указывает на этот сервер (A-запись)${NC}"
    exit 1
fi

# Копирование конфигурационных файлов
echo -e "${YELLOW}📋 Подготовка конфигурации...${NC}"

# Копируем nginx.conf
cp nginx/nginx.conf config/nginx.conf

# Копируем и обновляем index.html
cp nginx/html/index.html config/index.html
sed -i "s|PROXY_LINK|$TG_LINK|g" config/index.html

echo -e "${GREEN}✓ Конфигурация подготовлена${NC}"

# Загрузка образов из GitHub
echo -e "${YELLOW}📦 Загрузка Docker образов из GitHub Container Registry...${NC}"
docker pull ghcr.io/safe-stream/free-telegram-nginx:latest
docker pull ghcr.io/safe-stream/free-telegram-mtproxy:latest
echo -e "${GREEN}✓ Образы загружены${NC}"

# Запуск контейнеров
echo -e "${YELLOW}🚀 Запуск сервисов...${NC}"
docker-compose up -d

# Проверка статуса
sleep 5
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓ Сервисы успешно запущены!${NC}"
else
    echo -e "${RED}❌ Ошибка запуска сервисов${NC}"
    docker-compose logs
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✓ УСТАНОВКА ЗАВЕРШЕНА!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}🌐 Сайт доступен по адресу:${NC}"
echo -e "   https://free-telegram.link"
echo ""
echo -e "${BLUE}📱 Ссылки для Telegram:${NC}"
echo -e "   Direct: ${GREEN}$TG_LINK${NC}"
echo -e "   Universal: ${GREEN}$TG_LINK_T_ME${NC}"
echo ""
echo -e "${BLUE}📊 Проверка статуса:${NC} docker-compose ps"
echo -e "${BLUE}📜 Просмотр логов:${NC} docker-compose logs -f"
echo -e "${BLUE}🔄 Перезапуск:${NC} docker-compose restart"
echo -e "${BLUE}🛑 Остановка:${NC} docker-compose down"
echo ""
echo -e "${YELLOW}⚡ Настройка автообновления SSL сертификата:${NC}"
echo -e "   Certbot автоматически обновляет сертификаты каждые 12 часов"
echo ""

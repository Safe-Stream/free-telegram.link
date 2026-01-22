#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN} Free Telegram Proxy - Installation Script${NC}"
echo -e "${GREEN}============================================${NC}\n"

# Проверка root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED} This script must be run as root${NC}" 
   exit 1
fi

# Обновление системы
echo -e "${YELLOW} Updating system...${NC}"
apt-get update
apt-get upgrade -y
echo -e "${GREEN} System updated${NC}\n"

# Установка зависимостей
echo -e "${YELLOW} Installing dependencies...${NC}"
apt-get install -y git curl build-essential libssl-dev zlib1g-dev
echo -e "${GREEN} Dependencies installed${NC}\n"

# Установка Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW} Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN} Docker installed${NC}\n"
else
    echo -e "${GREEN} Docker already installed${NC}\n"
fi

# Установка Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW} Installing Docker Compose...${NC}"
    apt-get install -y docker-compose-plugin
    echo -e "${GREEN} Docker Compose installed${NC}\n"
else
    echo -e "${GREEN} Docker Compose already installed${NC}\n"
fi

# Установка MTProxy
echo -e "${YELLOW} Installing MTProxy...${NC}"
cd /opt
if [ -d "MTProxy" ]; then
    rm -rf MTProxy
fi
git clone https://github.com/TelegramMessenger/MTProxy.git
cd MTProxy
make
cp objs/bin/mtproto-proxy /usr/local/bin/
cd /opt/free-telegram.link

# Генерация SECRET для MTProxy
if [ ! -f .env ]; then
    echo -e "${YELLOW} Generating MTProxy SECRET...${NC}"
    SECRET=$(head -c 16 /dev/urandom | xxd -ps)
    echo "MTPROXY_SECRET=$SECRET" > .env
    echo -e "${GREEN} SECRET generated: $SECRET${NC}\n"
else
    echo -e "${GREEN} .env file already exists${NC}\n"
    source .env
    SECRET=$MTPROXY_SECRET
fi

# Скачивание конфигов Telegram
echo -e "${YELLOW} Downloading Telegram configs...${NC}"
mkdir -p /opt/mtproxy
curl -s https://core.telegram.org/getProxySecret -o /opt/mtproxy/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o /opt/mtproxy/proxy-multi.conf
echo -e "${GREEN} Configs downloaded${NC}\n"

# Создание systemd сервиса для MTProxy
echo -e "${YELLOW} Creating MTProxy service...${NC}"
cat > /etc/systemd/system/mtproxy.service << EOF
[Unit]
Description=MTProxy - Telegram Proxy
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/local/bin/mtproto-proxy -u nobody -p 8443 -H 8443 -S $SECRET --aes-pwd /opt/mtproxy/proxy-secret /opt/mtproxy/proxy-multi.conf -M 1
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable mtproxy
systemctl start mtproxy
echo -e "${GREEN} MTProxy service created and started${NC}\n"

# Создание директорий для certbot
mkdir -p certbot/conf certbot/www

# Получение SSL сертификата
echo -e "${YELLOW} Obtaining SSL certificate...${NC}"
read -p "Enter your email for Let's Encrypt notifications: " EMAIL
read -p "Enter your domain (e.g., free-telegram.link): " DOMAIN

docker run --rm \
    -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
    -v "$(pwd)/certbot/www:/var/www/certbot" \
    -p 80:80 \
    certbot/certbot certonly --standalone \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    -d "$DOMAIN"

if [ $? -eq 0 ]; then
    echo -e "${GREEN} SSL certificate obtained${NC}\n"
else
    echo -e "${RED} Failed to obtain SSL certificate${NC}"
    exit 1
fi

# Загрузка Nginx образа из GitHub
echo -e "${YELLOW} Pulling Nginx image from GitHub...${NC}"
docker pull ghcr.io/safe-stream/free-telegram.link-nginx:latest
echo -e "${GREEN} Image pulled${NC}\n"

# Запуск контейнеров
echo -e "${YELLOW} Starting containers...${NC}"
docker compose up -d
echo -e "${GREEN} Containers started${NC}\n"

# Вывод информации
PROXY_LINK="tg://proxy?server=$DOMAIN&port=8443&secret=$SECRET"
echo -e "${GREEN}${NC}"
echo -e "${GREEN} Installation completed!${NC}"
echo -e "${GREEN}${NC}"
echo -e "${YELLOW} Proxy Link:${NC}"
echo -e "${GREEN}$PROXY_LINK${NC}"
echo -e "${YELLOW} Website:${NC} https://$DOMAIN"
echo -e "${YELLOW} MTProxy Status:${NC} systemctl status mtproxy"
echo -e "${GREEN}${NC}"

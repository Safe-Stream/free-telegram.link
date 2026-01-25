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

# Создание системного пользователя mtproxy
echo -e "${YELLOW} Creating mtproxy system user...${NC}"
if ! id -u mtproxy > /dev/null 2>&1; then
    useradd -r -s /bin/false mtproxy
    echo -e "${GREEN} User 'mtproxy' created${NC}\n"
else
    echo -e "${GREEN} User 'mtproxy' already exists${NC}\n"
fi

# Генерация SECRET для MTProxy
if [ ! -f .env ]; then
    echo -e "${YELLOW} Generating MTProxy SECRET...${NC}"
    MTPROXY_SECRET=$(head -c 16 /dev/urandom | xxd -ps)
    
    cat > .env << ENVEOF
MTPROXY_SECRET=$MTPROXY_SECRET
LETSENCRYPT_EMAIL=
DOMAIN=
ENVEOF
    echo -e "${GREEN} SECRET generated: $MTPROXY_SECRET${NC}\n"
else
    echo -e "${GREEN} .env file already exists${NC}\n"
    source .env
fi

# Скачивание конфигов Telegram
echo -e "${YELLOW} Downloading Telegram configs...${NC}"
mkdir -p /opt/mtproxy
curl -s https://core.telegram.org/getProxySecret -o /opt/mtproxy/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o /opt/mtproxy/proxy-multi.conf
chown -R mtproxy:mtproxy /opt/mtproxy
echo -e "${GREEN} Configs downloaded${NC}\n"

# Создание systemd сервиса для MTProxy
echo -e "${YELLOW} Creating MTProxy service...${NC}"
cat > /etc/systemd/system/mtproxy.service << 'EOF'
[Unit]
Description=MTProxy - Telegram Proxy
After=network.target
Before=docker.service

[Service]
Type=simple
User=mtproxy
Group=mtproxy
EnvironmentFile=/opt/free-telegram.link/.env
ExecStart=/usr/local/bin/mtproto-proxy -p 8443 -S ${MTPROXY_SECRET} --aes-pwd /opt/mtproxy/proxy-secret /opt/mtproxy/proxy-multi.conf -M 4
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Запуск сервиса
systemctl daemon-reload
systemctl enable mtproxy
systemctl start mtproxy
echo -e "${GREEN} MTProxy service created and started (4 workers for 8-core CPU)${NC}\n"

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

# Генерация config.js для веб-сайта
echo -e "${YELLOW} Generating config.js for website...${NC}"
source .env
cat > nginx/html/config.js << CONFIGEOF
// Auto-generated proxy configuration
const PROXY_CONFIG = [{
    port: 8443,
    secret: '${MTPROXY_SECRET}'
}];
CONFIGEOF

# Обновление index.html с правильным секретом
sed -i "s/PLACEHOLDER_SECRET/${MTPROXY_SECRET}/g" nginx/html/index.html

# Пересоздать Nginx контейнер для применения config.js
docker compose restart nginx
echo -e "${GREEN} config.js generated and applied${NC}\n"

# Вывод информации
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✅ Installation completed!${NC}"
echo -e "${GREEN}============================================${NC}\n"
echo -e "${YELLOW}📍 Proxy Link:${NC}\n"
echo -e "${GREEN}tg://proxy?server=\$DOMAIN&port=8443&secret=dd${MTPROXY_SECRET}${NC}\n"
echo -e "${YELLOW}🌐 Website:${NC} https://\$DOMAIN${NC}"
echo -e "${YELLOW}📊 MTProxy Status:${NC} systemctl status mtproxy${NC}"
echo -e "${YELLOW}📊 MTProxy Logs:${NC} journalctl -u mtproxy -f${NC}\n"
echo -e "${GREEN}============================================${NC}"

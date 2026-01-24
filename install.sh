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

# Генерация 4 SECRET для MTProxy
if [ ! -f .env ]; then
    echo -e "${YELLOW} Generating 4 MTProxy SECRETs...${NC}"
    SECRET_2222=$(head -c 16 /dev/urandom | xxd -ps)
    SECRET_4444=$(head -c 16 /dev/urandom | xxd -ps)
    SECRET_3333=$(head -c 16 /dev/urandom | xxd -ps)
    SECRET_5555=$(head -c 16 /dev/urandom | xxd -ps)
    
    cat > .env << ENVEOF
MTPROXY_SECRET_2222=$SECRET_2222
MTPROXY_SECRET_4444=$SECRET_4444
MTPROXY_SECRET_3333=$SECRET_3333
MTPROXY_SECRET_5555=$SECRET_5555
LETSENCRYPT_EMAIL=
DOMAIN=
ENVEOF
    echo -e "${GREEN} 4 SECRETs generated${NC}\n"
else
    echo -e "${GREEN} .env file already exists${NC}\n"
    source .env
    SECRET_2222=$MTPROXY_SECRET_2222
    SECRET_4444=$MTPROXY_SECRET_4444
    SECRET_3333=$MTPROXY_SECRET_3333
    SECRET_5555=$MTPROXY_SECRET_5555
fi

# Скачивание конфигов Telegram
echo -e "${YELLOW} Downloading Telegram configs...${NC}"
mkdir -p /opt/mtproxy
curl -s https://core.telegram.org/getProxySecret -o /opt/mtproxy/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o /opt/mtproxy/proxy-multi.conf
echo -e "${GREEN} Configs downloaded${NC}\n"

# Создание директории для секретов
echo -e "${YELLOW} Creating MTProxy services...${NC}"
mkdir -p /opt/mtproxy/secrets

# Создание файлов с секретами для каждого порта
echo "SECRET=$SECRET_2222" > /opt/mtproxy/secrets/2222.env
echo "SECRET=$SECRET_4444" > /opt/mtproxy/secrets/4444.env
echo "SECRET=$SECRET_3333" > /opt/mtproxy/secrets/3333.env
echo "SECRET=$SECRET_5555" > /opt/mtproxy/secrets/5555.env

# Создание systemd template сервиса для MTProxy
cat > /etc/systemd/system/mtproxy@.service << 'EOF'
[Unit]
Description=MTProxy - Telegram Proxy (Port %i)
After=network.target

[Service]
Type=simple
User=nobody
EnvironmentFile=/opt/mtproxy/secrets/%i.env
ExecStart=/usr/local/bin/mtproto-proxy -u nobody -p %i -S ${SECRET} --aes-pwd /opt/mtproxy/proxy-secret /opt/mtproxy/proxy-multi.conf -M 2
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Запуск всех 4 сервисов
systemctl daemon-reload
systemctl enable mtproxy@2222 mtproxy@4444 mtproxy@3333 mtproxy@5555
systemctl start mtproxy@2222 mtproxy@4444 mtproxy@3333 mtproxy@5555
echo -e "${GREEN} 4 MTProxy services created and started${NC}\n"

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

# Генерация config.js для веб-сайта с секретами
echo -e "${YELLOW} Generating config.js for website...${NC}"
cat > nginx/html/config.js << CONFIGEOF
// Auto-generated proxy configuration
const PROXY_CONFIG = [
    {port: 2222, secret: '$SECRET_2222'},
    {port: 4444, secret: '$SECRET_4444'},
    {port: 3333, secret: '$SECRET_3333'},
    {port: 5555, secret: '$SECRET_5555'}
];
CONFIGEOF

# Пересоздать Nginx контейнер для применения config.js
docker compose restart nginx
echo -e "${GREEN} config.js generated and applied${NC}\n"

# Вывод информации
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✅ Installation completed!${NC}"
echo -e "${GREEN}============================================${NC}\n"
echo -e "${YELLOW}📍 Proxy Links:${NC}\n"
echo -e "${GREEN}Port 2222: tg://proxy?server=$DOMAIN&port=2222&secret=$SECRET_2222${NC}"
echo -e "${GREEN}Port 4444: tg://proxy?server=$DOMAIN&port=4444&secret=$SECRET_4444${NC}"
echo -e "${GREEN}Port 3333: tg://proxy?server=$DOMAIN&port=3333&secret=$SECRET_3333${NC}"
echo -e "${GREEN}Port 5555: tg://proxy?server=$DOMAIN&port=5555&secret=$SECRET_5555${NC}\n"
echo -e "${YELLOW}🌐 Website:${NC} https://$DOMAIN${NC}"
echo -e "${YELLOW}📊 MTProxy Status:${NC} systemctl status mtproxy@{2222,4444,3333,5555}${NC}\n"
echo -e "${GREEN}============================================${NC}"

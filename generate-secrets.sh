#!/bin/bash

# Скрипт для генерации 4 секретов MTProxy
# Использование: ./generate-secrets.sh

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}   MTProxy Secrets Generator (x4)${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Generating 4 secrets for MTProxy ports...${NC}\n"

SECRET_2222=$(head -c 16 /dev/urandom | xxd -ps)
SECRET_4444=$(head -c 16 /dev/urandom | xxd -ps)
SECRET_3333=$(head -c 16 /dev/urandom | xxd -ps)
SECRET_5555=$(head -c 16 /dev/urandom | xxd -ps)

echo -e "${GREEN}✓ Secrets generated!${NC}\n"

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "Port 2222: ${GREEN}$SECRET_2222${NC}"
echo -e "Port 4444: ${GREEN}$SECRET_4444${NC}"
echo -e "Port 3333: ${GREEN}$SECRET_3333${NC}"
echo -e "Port 5555: ${GREEN}$SECRET_5555${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Add to .env file:${NC}\n"
cat << EOF
MTPROXY_SECRET_2222=$SECRET_2222
MTPROXY_SECRET_4444=$SECRET_4444
MTPROXY_SECRET_3333=$SECRET_3333
MTPROXY_SECRET_5555=$SECRET_5555
EOF

echo -e "\n${YELLOW}Proxy links:${NC}\n"
echo "tg://proxy?server=YOUR_DOMAIN&port=2222&secret=$SECRET_2222"
echo "tg://proxy?server=YOUR_DOMAIN&port=4444&secret=$SECRET_4444"
echo "tg://proxy?server=YOUR_DOMAIN&port=3333&secret=$SECRET_3333"
echo "tg://proxy?server=YOUR_DOMAIN&port=5555&secret=$SECRET_5555"

echo -e "\n${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Done!${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}\n"

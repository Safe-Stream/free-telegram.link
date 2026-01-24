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

SECRET_8443=$(head -c 16 /dev/urandom | xxd -ps)
SECRET_8444=$(head -c 16 /dev/urandom | xxd -ps)
SECRET_8445=$(head -c 16 /dev/urandom | xxd -ps)
SECRET_8446=$(head -c 16 /dev/urandom | xxd -ps)

echo -e "${GREEN}✓ Secrets generated!${NC}\n"

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "Port 8443: ${GREEN}$SECRET_8443${NC}"
echo -e "Port 8444: ${GREEN}$SECRET_8444${NC}"
echo -e "Port 8445: ${GREEN}$SECRET_8445${NC}"
echo -e "Port 8446: ${GREEN}$SECRET_8446${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Add to .env file:${NC}\n"
cat << EOF
MTPROXY_SECRET_8443=$SECRET_8443
MTPROXY_SECRET_8444=$SECRET_8444
MTPROXY_SECRET_8445=$SECRET_8445
MTPROXY_SECRET_8446=$SECRET_8446
EOF

echo -e "\n${YELLOW}Proxy links:${NC}\n"
echo "tg://proxy?server=YOUR_DOMAIN&port=8443&secret=$SECRET_8443"
echo "tg://proxy?server=YOUR_DOMAIN&port=8444&secret=$SECRET_8444"
echo "tg://proxy?server=YOUR_DOMAIN&port=8445&secret=$SECRET_8445"
echo "tg://proxy?server=YOUR_DOMAIN&port=8446&secret=$SECRET_8446"

echo -e "\n${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Done!${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}\n"

#!/bin/bash

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Обновление Telegram MTProxy Service       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Проверка root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Этот скрипт должен быть запущен с правами root${NC}" 
   exit 1
fi

# Проверка наличия docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose не установлен${NC}"
    exit 1
fi

# Сохраняем текущую директорию
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${YELLOW}🔄 Обновление кода из GitHub...${NC}"
git pull origin main || git pull origin master

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при обновлении из Git${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Код обновлен${NC}"

echo -e "${YELLOW}📦 Загрузка последних Docker образов...${NC}"
docker-compose pull

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при загрузке образов${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Образы обновлены${NC}"

echo -e "${YELLOW}🔄 Перезапуск сервисов...${NC}"
docker-compose down
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка при перезапуске сервисов${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        ✓ ОБНОВЛЕНИЕ ЗАВЕРШЕНО!                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Проверка статуса
sleep 3
docker-compose ps

echo ""
echo -e "${BLUE}📊 Статус сервисов:${NC}"
docker-compose ps | grep "Up" && echo -e "${GREEN}✓ Все сервисы работают${NC}" || echo -e "${RED}❌ Есть проблемы с сервисами${NC}"

echo ""
echo -e "${YELLOW}💡 Полезные команды:${NC}"
echo -e "  ${BLUE}Логи:${NC} docker-compose logs -f"
echo -e "  ${BLUE}Статус:${NC} docker-compose ps"
echo -e "  ${BLUE}Перезапуск:${NC} docker-compose restart"
echo ""

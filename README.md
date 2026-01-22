#  Free Telegram Proxy

[![Build Status](https://github.com/Safe-Stream/free-telegram.link/actions/workflows/docker-build.yml/badge.svg)](https://github.com/Safe-Stream/free-telegram.link/actions)
[![Docker](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/orgs/Safe-Stream/packages)

Бесплатный MTProxy сервер для доступа к Telegram без ограничений и блокировок.

**Быстрый доступ к Telegram** через защищенный прокси-сервер с автоматическим SSL и простым подключением одним кликом.

---

##  Возможности

-  **Бесплатный безлимитный доступ** к Telegram
-  **Официальный MTProxy протокол** от Telegram
-  **SSL/TLS шифрование** через Let''s Encrypt
-  **TCP BBR** для оптимальной производительности
-  **Автоматическое обновление** через GitHub Actions
-  **Один клик подключения** через веб-интерфейс
-  **Минималистичный дизайн** в стиле Safe Stream
-  **Docker + Systemd** для надежности

---

##  Демо

**Веб-сайт:** https://free-telegram.link

**Прокси ссылка:**
```
tg://proxy?server=free-telegram.link&port=8443&secret=ff19acb1dddd642936b0483fcdc0dd9a
```

---

##  Архитектура

- **Nginx** (Docker) - веб-сервер с SSL/TLS
- **MTProxy** (нативный) - Telegram прокси на порту 8443
- **Certbot** (Docker) - автоматическое обновление SSL
- **GitHub Actions** - CI/CD для Docker образов
- **TCP BBR** - оптимизация производительности

---

##  Быстрая установка

```bash
# 1. Клонировать репозиторий
cd /opt
git clone https://github.com/Safe-Stream/free-telegram.link.git
cd free-telegram.link

# 2. Запустить установку
chmod +x install.sh
./install.sh

# Введите email и домен когда попросит
```

Скрипт автоматически:
- Установит Docker и зависимости
- Скомпилирует MTProxy на сервере
- Получит SSL сертификат
- Настроит systemd сервис
- Запустит все контейнеры

---

##  Обновление

```bash
cd /opt/free-telegram.link
./update.sh
```

Или вручную:
```bash
git pull
docker compose pull
docker compose up -d --force-recreate
systemctl restart mtproxy
```

---

##  Управление

### Проверка статуса
```bash
# MTProxy
systemctl status mtproxy

# Docker контейнеры
docker ps
```

### Логи
```bash
# MTProxy
journalctl -u mtproxy -f

# Nginx
docker logs -f free-telegram-nginx
```

### Активные подключения
```bash
netstat -an | grep 8443 | grep ESTABLISHED | wc -l
```

---

##  Конфигурация

### Основные файлы
- `/opt/free-telegram.link/.env` - SECRET прокси
- `/opt/free-telegram.link/nginx/html/index.html` - веб-страница
- `/etc/systemd/system/mtproxy.service` - systemd сервис

### Изменение SECRET
```bash
nano /opt/free-telegram.link/.env
systemctl restart mtproxy
# Обновите ссылку на сайте в nginx/html/index.html
```

---

##  Безопасность

- SSL/TLS сертификаты от Let''s Encrypt
- Автоматическое обновление сертификатов каждые 12 часов
- Официальный протокол MTProxy
- TCP BBR congestion control

---

##  Производительность

- **TCP BBR** - оптимальная скорость и стабильность
- **Nginx** с оптимизированными настройками
- **Docker** для изоляции и масштабируемости
- **Systemd** для автозапуска и мониторинга

---

##  Firewall

```bash
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 8443/tcp  # MTProxy
ufw enable
```

---

##  Troubleshooting

### MTProxy не работает
```bash
journalctl -u mtproxy -n 100
systemctl restart mtproxy
```

### Nginx не работает
```bash
docker logs free-telegram-nginx
docker compose restart nginx
```

### SSL не работает
```bash
# Проверить срок действия
openssl x509 -in /etc/letsencrypt/live/free-telegram.link/cert.pem -noout -dates

# Обновить сертификат
docker run --rm \
  -v ./certbot/conf:/etc/letsencrypt \
  -v ./certbot/www:/var/www/certbot \
  certbot/certbot renew
```

---

##  Поддержка

Проект от **Safe Stream VPN** для обеспечения доступа к Telegram.

- **Telegram:** [@Safe_Stream_bot](https://t.me/Safe_Stream_bot)
- **GitHub Issues:** [Создать Issue](https://github.com/Safe-Stream/free-telegram.link/issues)

---

##  Лицензия

MIT License - свободное использование и модификация

---

##  Благодарности

- [Telegram MTProxy](https://github.com/TelegramMessenger/MTProxy)
- [Let''s Encrypt](https://letsencrypt.org/)
- [Docker](https://www.docker.com/)
- [Nginx](https://nginx.org/)

---

**Сделано с  командой Safe Stream VPN**

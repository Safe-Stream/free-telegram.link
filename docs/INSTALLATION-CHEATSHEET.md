# 🚀 Шпаргалка по установке Free Telegram Proxy v2.1

## ⚡ Быстрая установка (5 минут)

```bash
# 1. Клонирование репозитория
cd /opt
sudo git clone https://github.com/safe-stream/free-telegram.link.git
cd free-telegram.link

# 2. Запуск установки
sudo chmod +x install.sh
sudo ./install.sh

# Скрипт запросит:
# - Email для Let's Encrypt
# - Домен (например: free-telegram.link)
```

## 🔥 Открытие портов в UFW

```bash
sudo ufw allow 80/tcp      # HTTP (для certbot)
sudo ufw allow 443/tcp     # HTTPS (веб-интерфейс)
sudo ufw allow 8443/tcp    # MTProxy (основной)
sudo ufw allow 8080/tcp    # MTProxy (альтернативный)
sudo ufw allow 1080/tcp    # MTProxy (альтернативный)
sudo ufw reload
sudo ufw status
```

## ☁️ Открытие портов у провайдера

**Hetzner Cloud:**
```bash
# Firewall → Rules → Add Rule
# TCP: 80, 443, 8443, 8080, 1080
# Source: 0.0.0.0/0 (Any IPv4)
```

**DigitalOcean:**
```bash
# Networking → Firewalls → Create Firewall
# Inbound Rules: TCP 80,443,8443,8080,1080
```

**AWS EC2:**
```bash
# Security Groups → Inbound Rules → Add Rule
# Custom TCP: 8443, 8080, 1080
# Source: 0.0.0.0/0
```

## 📊 Проверка после установки

```bash
# Статус MTProxy
sudo systemctl status mtproxy

# Статус таймера автообновления
sudo systemctl status mtproxy-update-config.timer

# Проверка портов
sudo ss -tulpn | grep mtproto-proxy

# Должно показать:
# tcp   LISTEN  0.0.0.0:8443
# tcp   LISTEN  0.0.0.0:8080
# tcp   LISTEN  0.0.0.0:1080
# tcp   LISTEN  127.0.0.1:8888

# Логи
sudo journalctl -u mtproxy -f

# Статистика
curl http://localhost:8888/stats
```

## 🌐 DNS настройка

**Для одного сервера:**
```
A    @    87.120.93.81      TTL 300
```

**Для балансировки (3+ сервера):**
```
A    @    87.120.93.81      TTL 300
A    @    87.120.93.82      TTL 300
A    @    87.120.93.83      TTL 300
```

## 🔗 Получение прокси ссылок

После установки скрипт выведет:
```
📍 Proxy Links:

Port 8443: tg://proxy?server=YOUR_DOMAIN&port=8443&secret=ddXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Port 8080: tg://proxy?server=YOUR_DOMAIN&port=8080&secret=ddXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Port 1080: tg://proxy?server=YOUR_DOMAIN&port=1080&secret=ddXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

🌐 Website: https://YOUR_DOMAIN
```

Или получить вручную:
```bash
cd /opt/free-telegram.link
source .env
echo "tg://proxy?server=YOUR_DOMAIN&port=8443&secret=dd${MTPROXY_SECRET}"
```

## 🛠️ Основные команды

```bash
# Перезапуск MTProxy
sudo systemctl restart mtproxy

# Остановка
sudo systemctl stop mtproxy

# Запуск
sudo systemctl start mtproxy

# Логи (последние 100 строк)
sudo journalctl -u mtproxy -n 100

# Логи (в реальном времени)
sudo journalctl -u mtproxy -f

# Ручное обновление конфигов Telegram
sudo /opt/free-telegram.link/scripts/update-config.sh

# Проверка таймера автообновления
sudo systemctl list-timers mtproxy-update-config.timer

# Форсировать обновление конфигов сейчас
sudo systemctl start mtproxy-update-config.service
```

## 🔧 Изменение конфигурации

### Изменить количество воркеров

```bash
sudo nano /etc/systemd/system/mtproxy.service

# Найти строку:
ExecStart=... -M 4

# Изменить на нужное (для 16 ядер = 8 воркеров):
ExecStart=... -M 8

# Применить
sudo systemctl daemon-reload
sudo systemctl restart mtproxy
```

### Добавить/удалить порты

```bash
sudo nano /etc/systemd/system/mtproxy.service

# Найти строку:
ExecStart=... -H 8443 -H 8080 -H 1080 ...

# Добавить новый порт:
ExecStart=... -H 8443 -H 8080 -H 1080 -H 3128 ...

# Применить
sudo systemctl daemon-reload
sudo systemctl restart mtproxy

# Открыть в UFW
sudo ufw allow 3128/tcp
```

### Изменить время автообновления

```bash
sudo nano /etc/systemd/system/mtproxy-update-config.timer

# Найти строку:
OnCalendar=03:00

# Изменить на нужное (например, 05:30):
OnCalendar=05:30

# Применить
sudo systemctl daemon-reload
sudo systemctl restart mtproxy-update-config.timer
```

## 🐛 Решение проблем

### MTProxy не запускается

```bash
# Проверить логи
sudo journalctl -u mtproxy -n 50

# Проверить что порты не заняты
sudo ss -tulpn | grep -E "8443|8080|1080"

# Проверить что пользователь mtproxy создан
id mtproxy

# Проверить права на конфиги
ls -la /opt/mtproxy/
# Должно быть: mtproxy:mtproxy
```

### Порты заблокированы

```bash
# Проверить UFW
sudo ufw status verbose

# Проверить iptables
sudo iptables -L -n

# Проверить что сервис слушает порт
sudo ss -tulpn | grep mtproto-proxy

# Проверить извне (с другого сервера)
nc -zv YOUR_DOMAIN 8443
```

### Ошибка SSL сертификата

```bash
# Проверить что домен указывает на сервер
dig YOUR_DOMAIN +short

# Перевыпустить сертификат
cd /opt/free-telegram.link
sudo docker run --rm \
    -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
    -v "$(pwd)/certbot/www:/var/www/certbot" \
    -p 80:80 \
    certbot/certbot certonly --standalone \
    --email YOUR_EMAIL \
    --agree-tos \
    -d YOUR_DOMAIN \
    --force-renewal
```

## 📈 Мониторинг производительности

```bash
# CPU и RAM
htop

# Сетевой трафик (установить если нет)
sudo apt install iftop
sudo iftop -i eth0

# Количество соединений
sudo ss -s

# Статистика MTProxy
watch -n 1 'curl -s localhost:8888/stats | jq'
```

## 🔄 Обновление проекта

```bash
cd /opt/free-telegram.link
sudo git pull origin main
sudo ./update.sh
```

## 📞 Поддержка

- 🐛 [GitHub Issues](https://github.com/safe-stream/free-telegram.link/issues)
- 💬 [@Safe_Stream_bot](https://t.me/Safe_Stream_bot)

---

**v2.1 Production** | Last updated: 2026-01-25

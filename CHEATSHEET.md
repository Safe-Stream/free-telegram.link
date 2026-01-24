# 📋 Шпаргалка - Free Telegram Proxy

## 🔐 Доступ к серверу

```bash
# SSH подключение
ssh root@62.133.61.144

# Пароль: [ЗАПОЛНИТЕ_ВАШ_ПАРОЛЬ]
```

**IP:** `62.133.61.144`  
**Домен:** `free-telegram.link`  
**Локация:** Amsterdam, Netherlands  
**ОС:** Ubuntu 24.04 LTS

---

## 📁 Структура директорий на сервере

```
/opt/free-telegram.link/          # Основная директория проекта
├── .env                          # Переменные окружения (SECRET)
├── docker-compose.yml            # Конфигурация контейнеров
├── install.sh                    # Скрипт установки
├── update.sh                     # Скрипт обновления
├── nginx/                        # Конфигурация Nginx
│   ├── Dockerfile
│   ├── nginx.conf
│   └── html/index.html           # Веб-страница
├── certbot/                      # SSL сертификаты
│   ├── conf/                     # Конфигурация Certbot
│   └── www/                      # ACME challenge
└── .github/                      # CI/CD
    └── workflows/docker-build.yml

/opt/mtproxy/                     # MTProxy конфигурация
├── proxy-secret                  # Telegram secret
└── proxy-multi.conf              # Telegram config

/opt/MTProxy/                     # Исходники MTProxy (после сборки)
└── objs/bin/mtproto-proxy        # Бинарник

/usr/local/bin/mtproto-proxy      # Установленный MTProxy

/etc/systemd/system/mtproxy.service  # Systemd сервис MTProxy

/opt/monitoring/                  # Мониторинг (Prometheus + Grafana)
├── docker-compose.yml            # Стек мониторинга
├── prometheus/
│   └── prometheus.yml            # Конфигурация Prometheus
└── grafana/
    └── provisioning/
        └── datasources/
            └── prometheus.yml    # Автоматическое подключение

/etc/letsencrypt/                 # SSL сертификаты Let's Encrypt
├── live/free-telegram.link/
│   ├── fullchain.pem             # Полная цепочка сертификата
│   ├── privkey.pem               # Приватный ключ
│   ├── cert.pem                  # Сертификат
│   └── chain.pem                 # Цепочка CA
└── archive/                      # Архив старых сертификатов
```

---

## 🔑 Важные данные

**MTProxy SECRETS (4 порта):**
```bash
cat /opt/free-telegram.link/.env
# или отдельные файлы:
cat /opt/mtproxy/secrets/2222.env
cat /opt/mtproxy/secrets/4444.env
cat /opt/mtproxy/secrets/3333.env
cat /opt/mtproxy/secrets/5555.env
```

**Прокси ссылки:**
```
Port 2222: tg://proxy?server=free-telegram.link&port=2222&secret=<SECRET_2222>
Port 4444: tg://proxy?server=free-telegram.link&port=4444&secret=<SECRET_4444>
Port 3333: tg://proxy?server=free-telegram.link&port=3333&secret=<SECRET_3333>
Port 5555: tg://proxy?server=free-telegram.link&port=5555&secret=<SECRET_5555>
```

**Сайт:** https://free-telegram.link

**GitHub:** https://github.com/Safe-Stream/free-telegram.link

---

## 🔍 Проверка статуса

### MTProxy (4 сервиса)
```bash
# Статус всех сервисов
systemctl status mtproxy@{2222,4444,3333,5555}

# Статус одного сервиса
systemctl status mtproxy@2222

# Рестарт всех
systemctl restart mtproxy@{2222,4444,3333,5555}

# Рестарт одного
systemctl restart mtproxy@4444

# Логи всех сервисов
journalctl -u "mtproxy@*" -f

# Логи одного порта
journalctl -u mtproxy@2222 -f

# Активные подключения по портам
echo "Port 2222: $(netstat -an | grep 2222 | grep ESTABLISHED | wc -l)"
echo "Port 4444: $(netstat -an | grep 4444 | grep ESTABLISHED | wc -l)"
echo "Port 3333: $(netstat -an | grep 3333 | grep ESTABLISHED | wc -l)"
echo "Port 5555: $(netstat -an | grep 5555 | grep ESTABLISHED | wc -l)"
```

### Docker
```bash
docker ps
docker logs free-telegram-nginx
docker compose restart
```

---

## 📜 Логи

```bash
# MTProxy (все сервисы)
journalctl -u "mtproxy@*" -f
journalctl -u "mtproxy@*" -n 50

# MTProxy (конкретный порт)
journalctl -u mtproxy@2222 -f
journalctl -u mtproxy@4444 -n 50

# Nginx
docker logs -f free-telegram-nginx

# Certbot
docker logs free-telegram-certbot
```

---

## 🔒 SSL Сертификаты

```bash
# Проверка срока действия
openssl x509 -in /etc/letsencrypt/live/free-telegram.link/cert.pem -noout -dates

# Проверка на сайте
echo | openssl s_client -servername free-telegram.link -connect free-telegram.link:443 2>/dev/null | openssl x509 -noout -dates

# Ручное продление
docker run --rm \
  -v /opt/free-telegram.link/certbot/conf:/etc/letsencrypt \
  -v /opt/free-telegram.link/certbot/www:/var/www/certbot \
  certbot/certbot renew
```

**Автопродление:** Certbot контейнер обновляет каждые 12 часов

---

## 🔄 Обновление

```bash
cd /opt/free-telegram.link
git pull
docker compose pull
docker compose up -d --force-recreate
systemctl restart mtproxy@{2222,4444,3333,5555}
```

Или используйте:
```bash
./update.sh
```

---

## 🌐 Проверка доступности

```bash
ping free-telegram.link
curl -I https://free-telegram.link
nc -zv free-telegram.link 2222
```

---

## 🛠️ Изменение SECRET

```bash
# 1. Отредактировать
nano /opt/free-telegram.link/.env

# 2. Перезапустить MTProxy
systemctl restart mtproxy

# 3. Обновить HTML
nano /opt/free-telegram.link/nginx/html/index.html

# 4. Применить
docker compose up -d --force-recreate nginx
```

---

## 📊 Мониторинг

```bash
# Ресурсы системы
htop
df -h
free -h

# Docker статистика
docker stats

# Сетевая активность
iftop
```

---

## 🚨 Troubleshooting

### MTProxy не работает
```bash
# Проверить статус всех
systemctl status mtproxy@{2222,4444,3333,5555}

# Логи конкретного сервиса
journalctl -u mtproxy@2222 -n 100

# Проверить файлы
ls -la /opt/mtproxy/
ls -la /opt/mtproxy/secrets/
which mtproto-proxy

# Рестарт всех
systemctl restart mtproxy@{2222,4444,3333,5555}

# Рестарт конкретного
systemctl restart mtproxy@2222
```

### Nginx не работает
```bash
docker logs free-telegram-nginx
docker exec free-telegram-nginx nginx -t
docker compose up -d --force-recreate nginx
```

### Порт занят
```bash
# Проверить все порты MTProxy
netstat -tlnp | grep ':844[3-6]'

# Проверить конкретный порт
lsof -i :2222
lsof -i :4444

# Убить процесс
kill -9 <PID>

# Или рестартнуть сервис
systemctl restart mtproxy@2222
```

---

## � Мониторинг (Prometheus + Grafana)

### SSH Туннель для доступа
```bash
# Из Windows/Mac/Linux локально
ssh -L 3000:localhost:3000 -L 9090:localhost:9090 -L 9100:localhost:9100 root@62.133.61.144

# Открыть в браузере:
# Grafana: http://localhost:3000 (admin / SafeStream2026!)
# Prometheus: http://localhost:9090
# Node Exporter: http://localhost:9100/metrics
```

### Управление стеком мониторинга
```bash
# Запуск/остановка
cd /opt/monitoring
docker compose up -d
docker compose down

# Проверка статуса
docker compose ps
docker compose logs -f grafana
docker compose logs -f prometheus

# Перезапуск после изменений конфига
docker compose restart prometheus
docker compose restart grafana
```

### Импорт MTProxy Dashboard
```bash
# 1. Открыть Grafana: http://localhost:3000
# 2. Dashboards → Import
# 3. Загрузить файл: monitoring/dashboards/mtproxy-dashboard.json
# 4. Или скопировать на сервер:
scp monitoring/dashboards/mtproxy-dashboard.json root@62.133.61.144:/opt/monitoring/
```

### Проверка метрик
```bash
# Prometheus targets (должны быть UP)
curl http://localhost:9090/api/v1/targets | python3 -m json.tool

# Node Exporter метрики
curl http://localhost:9100/metrics | grep node_systemd_unit_state

# Статус MTProxy сервиса (должен быть state="active"=1)
curl http://localhost:9100/metrics | grep 'node_systemd_unit_state{name="mtproxy.service"'
```

### Графики в MTProxy Dashboard:
- **Status Panel** - Статус systemd сервиса (UP/DOWN)
- **Active Connections** - Количество TCP соединений
- **Network Traffic** - Входящий/исходящий трафик
- **TCP Connections Over Time** - График подключений
- **CPU/Memory Usage** - Ресурсы системы

---

## 🔐 Безопасность

```bash
# Firewall
ufw status
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 2222/tcp
ufw allow 4444/tcp
ufw allow 3333/tcp
ufw allow 5555/tcp
ufw enable

# Обновления
apt update && apt upgrade -y
```

---

## 🎯 Быстрые команды

```bash
# Перезапуск всего
systemctl restart mtproxy@{2222,4444,3333,5555} && docker compose restart

# Проверка статуса
systemctl status mtproxy@{2222,4444,3333,5555} && docker ps

# Обновление
cd /opt/free-telegram.link && git pull && docker compose pull && docker compose up -d --force-recreate && systemctl restart mtproxy@{2222,4444,3333,5555}

# Активные подключения (суммарно по всем портам)
echo "Total connections: $(netstat -an | grep -E ':844[3-6]' | grep ESTABLISHED | wc -l)"
echo "Port 2222: $(netstat -an | grep 2222 | grep ESTABLISHED | wc -l)"
echo "Port 4444: $(netstat -an | grep 4444 | grep ESTABLISHED | wc -l)"
echo "Port 3333: $(netstat -an | grep 3333 | grep ESTABLISHED | wc -l)"
echo "Port 5555: $(netstat -an | grep 5555 | grep ESTABLISHED | wc -l)"

# Проверка SSL
openssl x509 -in /etc/letsencrypt/live/free-telegram.link/cert.pem -noout -dates

# Быстрая проверка всего стека
systemctl status mtproxy && docker ps && cd /opt/monitoring && docker compose ps
```

---

## 📞 Ссылки

- **GitHub:** https://github.com/Safe-Stream/free-telegram.link
- **Actions:** https://github.com/Safe-Stream/free-telegram.link/actions
- **Packages:** https://github.com/Safe-Stream?tab=packages
- **Safe Stream:** https://t.me/Safe_Stream_bot
- **MTProxy бот:** https://t.me/MTProxybot

---

**Дата создания:** 23 января 2026  
**Резервную копию SECRET храните в безопасном месте!**

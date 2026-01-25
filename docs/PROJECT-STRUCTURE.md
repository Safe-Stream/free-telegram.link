# 📋 Структура проекта Free Telegram Proxy

## 📂 Корневые файлы

| Файл | Назначение |
|------|-----------|
| `install.sh` | **Основной скрипт установки**<br>Устанавливает все зависимости, компилирует MTProxy, настраивает systemd |
| `update.sh` | **Скрипт обновления**<br>Обновляет MTProxy и Docker образы |
| `docker-compose.yml` | **Docker Compose конфигурация**<br>Запускает nginx + certbot для веб-интерфейса |
| `.env.example` | **Шаблон переменных окружения**<br>MTPROXY_SECRET, DOMAIN, EMAIL |

## 📁 Директории

### `scripts/` - Утилиты

```
scripts/
└── update-config.sh        # Автообновление конфигов Telegram
                           # Скачивает proxy-secret и proxy-multi.conf
                           # Запускается systemd timer ежедневно в 03:00
```

### `systemd/` - Системные сервисы

```
systemd/
├── mtproxy.service.template              # Шаблон systemd сервиса
│                                         # Копируется в /etc/systemd/system/
│
├── mtproxy-update-config.service         # Service для обновления конфигов
│                                         # Вызывает scripts/update-config.sh
│
└── mtproxy-update-config.timer           # Timer для ежедневного запуска
                                          # OnCalendar=03:00
```

### `nginx/` - Веб-сервер и интерфейс

```
nginx/
├── Dockerfile                    # Образ nginx с конфигом
├── nginx.conf                    # Конфигурация nginx (SSL, reverse proxy)
└── html/
    ├── index.html                # Главная страница с кнопкой подключения
    └── config.js.template        # Шаблон конфигурации портов/секретов
                                  # Генерируется install.sh → config.js
```

### `docs/` - Документация

```
docs/
└── README.md                     # Полная документация проекта
                                  # Архитектура, управление, масштабирование
```

### `monitoring/` - Мониторинг (опционально)

```
monitoring/
└── (Prometheus + Grafana конфиги для продакшена)
```

## 🔧 Конфигурационные файлы на сервере

После установки создаются:

```
/opt/free-telegram.link/
├── .env                                  # Реальные секреты (не в Git!)
└── nginx/html/config.js                  # Сгенерированный config (не в Git!)

/opt/mtproxy/
├── proxy-secret                          # Telegram DC keys
└── proxy-multi.conf                      # Telegram DC addresses

/etc/systemd/system/
├── mtproxy.service                       # Systemd сервис MTProxy
├── mtproxy-update-config.service         # Service автообновления
└── mtproxy-update-config.timer           # Timer автообновления

/usr/local/bin/
└── mtproto-proxy                         # Скомпилированный бинарник
```

## 🔄 Workflow установки

1. **Клонирование репо** → `/opt/free-telegram.link`
2. **Запуск install.sh**:
   - Обновление системы
   - Установка Docker, build tools
   - Клонирование MTProxy из GitHub
   - Компиляция (`make`)
   - Создание пользователя `mtproxy`
   - Генерация SECRET
   - Скачивание конфигов Telegram
   - Копирование systemd файлов
   - Получение SSL сертификата
   - Генерация config.js
   - Запуск сервисов

3. **Результат**:
   - MTProxy работает на портах 8443, 8080, 1080
   - Статистика на localhost:8888
   - Веб-интерфейс на https://domain
   - Автообновление конфигов каждый день в 03:00

## 🎯 Ключевые особенности архитектуры

### Множественные порты
```bash
ExecStart=/usr/local/bin/mtproto-proxy \
    -u mtproxy \
    -p 8888 \              # Статистика (localhost)
    -H 8443 \              # Основной порт
    -H 8080 \              # Альтернативный
    -H 1080 \              # Альтернативный
    -S ${SECRET} \
    --aes-pwd /opt/mtproxy/proxy-secret \
    /opt/mtproxy/proxy-multi.conf \
    -M 4                   # 4 воркера для 8-core CPU
```

### Hot Reload конфигов
```bash
# scripts/update-config.sh
curl https://core.telegram.org/getProxySecret → proxy-secret
curl https://core.telegram.org/getProxyConfig → proxy-multi.conf
systemctl reload-or-restart mtproxy  # Без разрыва соединений!
```

### Client-side Load Balancing
```javascript
// nginx/html/index.html
const proxy = getUserProxy();  // Случайный порт для пользователя
localStorage.setItem('telegram_proxy_port', proxy.port);  // Sticky session
```

## 📊 Мониторинг

```bash
# Статус сервисов
systemctl status mtproxy
systemctl status mtproxy-update-config.timer

# Логи
journalctl -u mtproxy -f

# Статистика
curl localhost:8888/stats

# Проверка таймера
systemctl list-timers mtproxy-update-config.timer
```

## 🚀 Команды обновления

```bash
# Ручное обновление конфигов
/opt/free-telegram.link/scripts/update-config.sh

# Обновление MTProxy и Docker образов
cd /opt/free-telegram.link
sudo ./update.sh
```

---

**v2.1** • Оптимизировано для продакшена

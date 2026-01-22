# 🚀 Развертывание на сервер

## 1. Подключение к серверу

```bash
ssh root@62.133.61.144
```

## 2. Клонирование репозитория

```bash
cd /opt
git clone https://github.com/Safe-Stream/free-telegram.link.git
cd free-telegram.link
```

## 3. Запуск установки

```bash
chmod +x install.sh
./install.sh
```

Скрипт спросит:
- **Email** для Let's Encrypt уведомлений (например: admin@safe-stream.net)
- **Domain**: free-telegram.link

## 4. Что произойдет

✅ Обновление системы  
✅ Установка зависимостей  
✅ Установка Docker + Docker Compose  
✅ Компиляция MTProxy на сервере  
✅ Создание systemd сервиса для MTProxy (порт 8443)  
✅ Генерация SECRET  
✅ Получение SSL сертификата  
✅ Запуск Nginx в Docker (порт 443)  

## 5. Проверка работы

После установки откройте:
- **Сайт**: https://free-telegram.link
- **MTProxy статус**: `systemctl status mtproxy`
- **Логи Nginx**: `docker logs free-telegram-nginx`

## 6. Получение ссылки на прокси

Скрипт выведет готовую ссылку вида:
```
tg://proxy?server=free-telegram.link&port=8443&secret=XXXXXXXX
```

Эту ссылку разместите на сайте (кнопка уже готова в HTML).

## 7. Обновления в будущем

```bash
cd /opt/free-telegram.link
git pull
docker-compose pull
docker-compose up -d --force-recreate
systemctl restart mtproxy
```

Или используйте готовый скрипт:
```bash
./update.sh
```

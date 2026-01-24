#  Free Telegram Proxy

[![Build Status](https://github.com/Safe-Stream/free-telegram.link/actions/workflows/docker-build.yml/badge.svg)](https://github.com/Safe-Stream/free-telegram.link/actions)

Бесплатный MTProxy для доступа к Telegram без блокировок.

---

##  Возможности

-  Бесплатный безлимитный доступ к Telegram
-  SSL/TLS шифрование
-  Быстрое подключение одним кликом
-  Официальный протокол MTProxy
-  4 независимых прокси сервиса для балансировки нагрузки
-  Уникальные секреты для изоляции пользователей

---

##  Использование

**Веб-сайт:** https://free-telegram.link

Откройте сайт и нажмите кнопку "Открыть Telegram" - прокси подключится автоматически.

---

##  Установка на свой сервер

```bash
cd /opt
git clone https://github.com/Safe-Stream/free-telegram.link.git
cd free-telegram.link
chmod +x install.sh
./install.sh
```

Требования:
- Ubuntu 20.04+ (рекомендуется 24.04 LTS)
- Домен с DNS записью
- Открытые порты: 80, 443, 8443, 8444, 8445, 8446
- Минимум: 2 vCPU, 2 GB RAM
- Рекомендуется: 4+ vCPU, 4+ GB RAM для большой нагрузки

---

##  Обновление

```bash
cd /opt/free-telegram.link
./update.sh
```

---

##  Архитектура

Проект использует гибридную архитектуру для максимальной производительности и надежности:

### Компоненты:

- **Nginx (Docker)** - HTTPS веб-сервер для раздачи прокси ссылок
- **MTProxy (Native)** - 4 независимых systemd сервиса:
  - `mtproxy@8443.service` - порт 8443, уникальный секрет #1
  - `mtproxy@8444.service` - порт 8444, уникальный секрет #2
  - `mtproxy@8445.service` - порт 8445, уникальный секрет #3
  - `mtproxy@8446.service` - порт 8446, уникальный секрет #4
- **Certbot (Docker)** - автоматическое обновление SSL сертификатов

### Балансировка нагрузки:

Веб-сайт автоматически выдает случайную ссылку из 4 доступных прокси для равномерного распределения пользователей между сервисами. Это обеспечивает:

- ✅ Высокую производительность при большой нагрузке
- ✅ Изоляцию пользователей (разные секреты)
- ✅ Отказоустойчивость (если один сервис упал - остальные работают)

---

##  Поддержка

Проект от **Safe Stream VPN**

- Telegram: [@Safe_Stream_bot](https://t.me/Safe_Stream_bot)
- Issues: [GitHub](https://github.com/Safe-Stream/free-telegram.link/issues)

---

##  Лицензия

MIT License

---

**Сделано с  командой Safe Stream VPN**

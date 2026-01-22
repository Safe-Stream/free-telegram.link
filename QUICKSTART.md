# 🎯 БЫСТРЫЙ СТАРТ

## На сервере (один раз):

```bash
cd /opt
git clone https://github.com/Safe-Stream/free-telegram.link.git
cd free-telegram.link
chmod +x install.sh
./install.sh
```

## Обновление сервиса:

```bash
cd /opt/free-telegram.link
./update.sh
```

## На локальном ПК (разработка):

### Первый раз:
```powershell
cd C:\telegram-proxy
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/Safe-Stream/free-telegram.link.git
git branch -M main
git push -u origin main
```

### При изменениях:
```powershell
cd C:\telegram-proxy
.\git-push.ps1 "Описание изменений"
```

Или вручную:
```powershell
git add .
git commit -m "Update"
git push
```

---

## 📚 Полная документация:

- [README.md](README.md) - Основная документация
- [DEPLOY.md](DEPLOY.md) - Подробная инструкция по развертыванию
- [GITHUB.md](GITHUB.md) - Работа с GitHub и CI/CD

---

## ✅ Проверка статуса:

```bash
docker-compose ps
docker-compose logs -f
```

## 🌐 Ссылки:

- Сайт: https://free-telegram.link
- GitHub: https://github.com/Safe-Stream/free-telegram.link
- Docker образы: https://github.com/orgs/Safe-Stream/packages

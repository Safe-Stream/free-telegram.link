# Git Push Script
# Быстрая отправка изменений в GitHub

param(
    [string]$Message = "Update: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
)

Write-Host "🚀 Отправка изменений в GitHub..." -ForegroundColor Blue
Write-Host ""

# Проверка изменений
$status = git status --short
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "✓ Нет изменений для отправки" -ForegroundColor Green
    exit 0
}

Write-Host "Изменённые файлы:" -ForegroundColor Yellow
git status --short

Write-Host ""
Write-Host "Коммит сообщение: $Message" -ForegroundColor Cyan
Write-Host ""

# Добавление всех файлов
git add .

# Коммит
git commit -m $Message

# Push
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Изменения успешно отправлены в GitHub!" -ForegroundColor Green
    Write-Host ""
    Write-Host "GitHub Actions начнёт сборку образов..." -ForegroundColor Yellow
    Write-Host "Проверить статус: https://github.com/Safe-Stream/free-telegram.link/actions" -ForegroundColor Blue
} else {
    Write-Host ""
    Write-Host "❌ Ошибка при отправке" -ForegroundColor Red
}

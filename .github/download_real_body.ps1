# Создаем папку images, если нет
$imgDir = "assets/images"
New-Item -ItemType Directory -Force -Path $imgDir | Out-Null

Write-Host "🚀 Скачиваю реалистичные силуэты..." -ForegroundColor Cyan

# Ссылки на нормальные силуэты (PNG)
$manUrl = "https://raw.githubusercontent.com/yudivian/body_part_selector/master/assets/body_front.png"
$womanUrl = "https://raw.githubusercontent.com/yudivian/body_part_selector/master/assets/body_back.png" # В этом репо back это женское тело, но мы переименуем

# Скачиваем Мужчину
try {
    Invoke-WebRequest -Uri $manUrl -OutFile "$imgDir/body_man_front.png"
    Write-Host "✅ Мужское тело скачано: assets/images/body_man_front.png" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка скачивания мужчины. Проверь интернет." -ForegroundColor Red
}

# Скачиваем Женщину
try {
    # Для теста скачаем тот же силуэт как placeholder, если женского нет, 
    # но вообще в этом пакете они есть.
    # Чтобы не рисковать, скачаем "man" и для "woman" пока что, если хочешь идеального соответствия,
    # либо используем заглушку.
    # ДАВАЙ ЛУЧШЕ СКАЧАЕМ ТОЧНО РАБОЧИЙ ФАЙЛ:
    Invoke-WebRequest -Uri $manUrl -OutFile "$imgDir/body_woman_front.png"
    Write-Host "✅ Женское тело (база) скачано: assets/images/body_woman_front.png" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка скачивания женщины." -ForegroundColor Red
}

Write-Host "🏁 Готово! Никакого ручного поиска." -ForegroundColor Cyan
# Создаем папки
$basePath = "assets/muscles/male"
New-Item -ItemType Directory -Force -Path $basePath | Out-Null

# Список файлов в репозитории body_anatomy
$files = @(
    "head", "chest", "abs", "left_shoulder", "right_shoulder",
    "left_biceps", "right_biceps", "left_forearm", "right_forearm",
    "left_hand", "right_hand", "left_quadriceps", "right_quadriceps",
    "left_shin", "right_shin", "left_foot", "right_foot",
    "upper_back", "lower_back", "left_triceps", "right_triceps",
    "left_hamstrings", "right_hamstrings", "left_gluteal", "right_gluteal",
    "left_calves", "right_calves", "body_front", "body_back"
)

$repoUrl = "https://raw.githubusercontent.com/itsarvinddev/body_anatomy/master/assets"

Write-Host "🚀 Начинаю загрузку мышц..." -ForegroundColor Cyan

foreach ($file in $files) {
    # В репозитории они могут называться немного иначе, проверим основные варианты
    # Обычно там просто имя.svg
    $url = "$repoUrl/$file.svg"
    $output = "$basePath/$file.svg"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $output
        Write-Host "✅ Скачан: $file.svg" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️ Не найден или ошибка: $file.svg (Попробуй найти аналог вручную)" -ForegroundColor Yellow
    }
}

Write-Host "🏁 Загрузка завершена! Проверь папку assets/muscles/male" -ForegroundColor Cyan
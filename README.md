# OpenRocket Portable Builder

Автоматически собирает портабельную версию OpenRocket для Windows x64 — Java не нужна на целевом компьютере.

## Как работает

1. Клонирует ветку `unstable` из [openrocket/openrocket](https://github.com/openrocket/openrocket)
2. Собирает `shadowJar` (один `.jar` со всеми зависимостями)
3. `jpackage --type app-image` создаёт `OpenRocket.exe` + bundled JRE
4. Упаковывает всё в `.zip` — распакуй и запускай `OpenRocket.exe`

## Вариант 1: GitHub Actions (рекомендуется)

1. Создай публичный репозиторий на GitHub
2. Скопируй туда эту папку целиком
3. Actions запустится автоматически:
   - Каждый день в 06:00 UTC проверяет новые коммиты
   - Если есть — собирает и публикует `.zip` в Releases
   - Если нет — пропускает
4. Ручной запуск: Actions → `Build Portable OpenRocket` → `Run workflow`

Для работы Actions нужно включить **Write permissions** в настройках репозитория:  
`Settings → Actions → General → Workflow permissions → Read and write`

## Вариант 2: Локальная сборка

Требования: **JDK 17+** и **Git** в PATH.

```powershell
.\build.ps1
# или конкретная ветка:
.\build.ps1 -Ref release-24.12
```

Результат: `dist\OpenRocket-portable-win-x64-<sha>.zip`

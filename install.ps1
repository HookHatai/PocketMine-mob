# PocketMine-MP 1.6.2dev - Windows/PowerShell launcher
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "PocketMine-MP 1.6.2dev installer" -ForegroundColor Magenta
Write-Host "Этот установщик подготовит Ubuntu через WSL и запустит Linux-установщик."
Write-Host ""

$answer = Read-Host "Установить / подготовить Ubuntu? (Y or N)"
if ($answer -notmatch '^(Y|YES)$') {
    Write-Host "Установка отменена." -ForegroundColor Yellow
    exit 0
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "WSL не найден. Запрашиваю установку WSL и Ubuntu..." -ForegroundColor Cyan
    & wsl.exe --install -d Ubuntu
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Не удалось установить WSL/Ubuntu. Запусти PowerShell от имени администратора и повтори." -ForegroundColor Red
        exit 1
    }
    Write-Host ""
    Write-Host "Если Windows попросит перезагрузку — перезагрузи ПК, затем снова запусти этот файл." -ForegroundColor Yellow
    Write-Host "При первом запуске Ubuntu создай Linux-имя пользователя и пароль." -ForegroundColor Yellow
    exit 0
}

$distros = @(& wsl.exe --list --quiet 2>$null) | ForEach-Object { ($_ -replace "\0", "").Trim() } | Where-Object { $_ }
$ubuntu = $distros | Where-Object { $_ -match '^Ubuntu($|-)' } | Select-Object -First 1

if (-not $ubuntu) {
    Write-Host "Ubuntu ещё не установлена. Запускаю установку..." -ForegroundColor Cyan
    & wsl.exe --install -d Ubuntu
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Установка не завершилась. Возможно, нужна перезагрузка или запуск PowerShell от имени администратора." -ForegroundColor Red
        exit 1
    }
    Write-Host ""
    Write-Host "Теперь откроется Ubuntu. При первом запуске создай Linux-имя пользователя и пароль." -ForegroundColor Yellow
    & wsl.exe -d Ubuntu
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Не удалось запустить Ubuntu. Перезагрузи Windows и повтори запуск." -ForegroundColor Red
        exit 1
    }
    $ubuntu = "Ubuntu"
}

Write-Host ""
Write-Host "Запускаю установщик PocketMine внутри Ubuntu..." -ForegroundColor Cyan
$linuxCommand = 'if ! command -v git >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y git; fi; if [ ! -d "$HOME/PocketMine-mob/.git" ]; then git clone https://github.com/HookHatai/PocketMine-mob.git "$HOME/PocketMine-mob"; else cd "$HOME/PocketMine-mob" && git pull; fi && cd "$HOME/PocketMine-mob" && bash install-ubuntu.sh'
& wsl.exe -d $ubuntu -- bash -lc $linuxCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "Linux-установщик завершился с ошибкой. Открой Ubuntu и проверь вывод выше." -ForegroundColor Red
    exit $LASTEXITCODE
}

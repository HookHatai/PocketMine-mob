# PocketMine-mob

Автоматическая установка PocketMine-MP 1.6.2dev для Android ARM64 через Termux + Debian proot-distro.

## Установка на чистом Termux

Выполни в Termux одну команду:

```bash
pkg update -y && pkg install -y git && git clone https://github.com/HookHatai/PocketMine-mob.git && cd PocketMine-mob && bash install.sh
```

Установщик автоматически:
- проверяет архитектуру ARM64;
- устанавливает Termux-инструменты и Debian;
- скачивает PHP 7.2.34 ZTS + pthreads/yaml/bcmath + PocketMine PHAR из GitHub Release;
- проверяет SHA-256 архива;
- устанавливает системные библиотеки Debian и проверяет PHP.

## Управление сервером

Команды доступны в Termux:

- `pmstart` — запуск PocketMine в фоновой tmux-сессии.
- `pmconsole` — подключение к консоли.
- `pmstop` — штатная остановка сервера.

Чтобы выйти из консоли, не останавливая сервер: нажми Ctrl+B, затем D.

## Установка на Ubuntu (WSL или Linux x86_64)

Выполни одну команду:

```bash
git clone https://github.com/HookHatai/PocketMine-mob.git && cd PocketMine-mob && bash install-ubuntu.sh
```

Установщик скачивает проверенный архив PHP 7.0.3 ZTS и PocketMine-MP 1.6.2dev, проверяет SHA-256 и создаёт команды управления.

### Управление сервером в Ubuntu

- `pmstart` — запуск сервера.
- `pmconsole` — открыть консоль.
- `pmstop` — штатно остановить сервер.

### Обновление установщика

```bash
cd ~/PocketMine-mob && git pull
```

### Удаление репозитория установщика

```bash
rm -rf ~/PocketMine-mob
```

Эта команда удаляет только папку с установщиком. Установленный сервер в `~/pocketmine-162dev-ubuntu-x64` остаётся.

## Установка через Windows PowerShell

Открой PowerShell и выполни:

```powershell
irm https://raw.githubusercontent.com/HookHatai/PocketMine-mob/main/install.ps1 | iex
```

Скрипт подготовит Ubuntu через WSL и запустит Linux-установщик. При необходимости запускай PowerShell от имени администратора.

## Сборка

Используется проверенный архив ARM64 из [GitHub Releases](https://github.com/HookHatai/PocketMine-mob/releases/tag/Phar).

- PocketMine-MP: 1.6.2dev (Unleashed)
- Minecraft PE: 1.1.0.55
- PHP: 7.2.34 ZTS
- Расширения: pthreads, yaml, bcmath

Сборка предназначена для Android ARM64. Это устаревшая версия PocketMine для совместимости с указанным старым клиентом Minecraft; она не является современной или поддерживаемой версией сервера.

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

## Сборка

Используется проверенный архив ARM64 из [GitHub Releases](https://github.com/HookHatai/PocketMine-mob/releases/tag/Phar).

- PocketMine-MP: 1.6.2dev (Unleashed)
- Minecraft PE: 1.1.0.55
- PHP: 7.2.34 ZTS
- Расширения: pthreads, yaml, bcmath

Сборка предназначена для Android ARM64. Это устаревшая версия PocketMine для совместимости с указанным старым клиентом Minecraft; она не является современной или поддерживаемой версией сервера.

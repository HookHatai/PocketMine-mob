# PocketMine-mob

Скрипты управления PocketMine-MP 1.6.2dev для Termux + Debian proot-distro.

## Установка

В Termux (не внутри Debian):

```bash
pkg update
pkg install git tmux proot-distro
git clone https://github.com/HookHatai/PocketMine-mob.git
cd PocketMine-mob
bash install.sh
```

## Команды

- `start` — запускает сервер в фоновой tmux-сессии.
- `console` — подключается к консоли сервера.
- `stop` — отправляет PocketMine команду штатной остановки.

Чтобы выйти из консоли, не останавливая сервер: нажми Ctrl+B, затем D.

## Требования

Этот репозиторий пока содержит только управляющие скрипты. Он НЕ скачивает и НЕ устанавливает автоматически Debian, PHP 7.2, расширения или PocketMine PHAR.

Ожидается, что в Debian уже существуют:

- `/root/pocketmine/PocketMine-MP.phar`
- `/opt/php72/bin/php`
- PHP-расширения pthreads, yaml и bcmath в `/opt/php72/lib/php/extensions/no-debug-zts-20170718/`

Скрипты запускают именно старую сборку PocketMine-MP 1.6.2dev через PHP 7.2 ZTS.

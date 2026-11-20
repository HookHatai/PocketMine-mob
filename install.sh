#!/data/data/com.termux/files/usr/bin/bash
set -e

if [ -z "${PREFIX:-}" ]; then
  echo "Запусти этот скрипт из Termux, не из Debian."
  exit 1
fi

for cmd in proot-distro tmux; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Не найдена команда: $cmd"
    if [ "$cmd" = "tmux" ]; then
      echo "Установи её командой: pkg install tmux"
    else
      echo "Установи proot-distro командой: pkg install proot-distro"
    fi
    exit 1
  fi
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$PREFIX/bin"

for cmd in start stop console; do
  chmod +x "$SCRIPT_DIR/$cmd"
  ln -sf "$SCRIPT_DIR/$cmd" "$PREFIX/bin/$cmd"
done

echo "Готово. Команды start, stop и console доступны в Termux."
echo "Важно: Debian и PocketMine с PHP 7.2 должны быть уже настроены."

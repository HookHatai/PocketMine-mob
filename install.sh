#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

REPO="https://github.com/HookHatai/PocketMine-mob"
BUNDLE_URL="https://github.com/HookHatai/PocketMine-mob/releases/download/Phar/pocketmine-162dev-arm64-bundle.tar.gz"
BUNDLE_SHA256="72fbb516576b120febaeed8a18934600b4aa6b24bad3b3cb51f549331d5689e6"
BUNDLE="$HOME/pocketmine-162dev-arm64-bundle.tar.gz"

if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX/bin" ]; then
  echo "Запусти этот установщик в Termux, не внутри Debian."
  exit 1
fi

ARCH="$(uname -m)"
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
  echo "Эта сборка предназначена для ARM64. Обнаружена архитектура: $ARCH"
  exit 1
fi

echo "[1/6] Устанавливаю инструменты Termux..."
pkg update -y
pkg install -y proot-distro tmux curl coreutils tar

echo "[2/6] Загружаю проверенный архив (около 46 МБ)..."
curl -fL --retry 3 "$BUNDLE_URL" -o "$BUNDLE"
echo "$BUNDLE_SHA256  $BUNDLE" | sha256sum -c -

echo "[3/6] Устанавливаю Debian..."
if ! proot-distro list 2>/dev/null | grep -qE '^debian([[:space:]]|$)'; then
  proot-distro install debian
else
  if [ ! -d "$PREFIX/var/lib/proot-distro/containers/debian/rootfs" ]; then
    proot-distro install debian
  fi
fi

ROOTFS="$PREFIX/var/lib/proot-distro/containers/debian/rootfs"
if [ ! -d "$ROOTFS" ]; then
  echo "Не найден rootfs Debian: $ROOTFS"
  exit 1
fi

echo "[4/6] Распаковываю PHP 7.2 и PocketMine в Debian..."
mkdir -p "$ROOTFS/opt" "$ROOTFS/root/pocketmine"
tar -xzf "$BUNDLE" -C "$ROOTFS"

echo "[5/6] Устанавливаю системные библиотеки Debian..."
proot-distro login debian -- bash -lc '
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates libxml2 libcurl4t64 libzip5 zlib1g libyaml-0-2 libssl3 libsqlite3-0
'

echo "[6/6] Проверяю PHP, расширения и PocketMine..."
proot-distro login debian -- bash -lc '
set -e
PHP=/opt/php72/bin/php
EXT=/opt/php72/lib/php/extensions/no-debug-zts-20170718
export LD_LIBRARY_PATH=/opt/php72/compat/usr/lib/aarch64-linux-gnu:/opt/php72/lib
for f in "$PHP" "$EXT/pthreads.so" "$EXT/yaml.so" "$EXT/bcmath.so" /root/pocketmine/PocketMine-MP.phar; do
  test -f "$f" || { echo "Не найден файл: $f"; exit 1; }
done
"$PHP" -v | head -n 1
"$PHP" -d extension="$EXT/pthreads.so" -d extension="$EXT/yaml.so" -d extension="$EXT/bcmath.so" -r '''
foreach (["pthreads", "yaml", "bcmath"] as $e) {
  if (!extension_loaded($e)) { fwrite(STDERR, "Missing extension: $e\\n"); exit(1); }
}
if (bcadd("1", "2") !== "3") { exit(2); }
echo "PHP extensions OK; BCMath OK\\n";
'''
'

cat > "$PREFIX/bin/pmstart" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -e
if tmux has-session -t pocketmine 2>/dev/null; then
  echo "PocketMine уже запущен. Введи pmconsole."
  exit 0
fi
tmux new-session -d -s pocketmine "proot-distro login debian -- bash -lc 'cd /root/pocketmine && export LD_LIBRARY_PATH=/opt/php72/compat/usr/lib/aarch64-linux-gnu:/opt/php72/lib && exec /opt/php72/bin/php -d extension=/opt/php72/lib/php/extensions/no-debug-zts-20170718/pthreads.so -d extension=/opt/php72/lib/php/extensions/no-debug-zts-20170718/yaml.so -d extension=/opt/php72/lib/php/extensions/no-debug-zts-20170718/bcmath.so PocketMine-MP.phar'"
sleep 2
if tmux has-session -t pocketmine 2>/dev/null; then
  echo "PocketMine запущен. Консоль: pmconsole"
else
  echo "Сервер завершился при запуске. Проверь: pmconsole"
  exit 1
fi
EOF

cat > "$PREFIX/bin/pmstop" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if tmux has-session -t pocketmine 2>/dev/null; then
  tmux send-keys -t pocketmine "stop" Enter
  echo "Команда остановки отправлена."
else
  echo "PocketMine не запущен."
fi
EOF

cat > "$PREFIX/bin/pmconsole" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
if tmux has-session -t pocketmine 2>/dev/null; then
  tmux attach-session -t pocketmine
else
  echo "PocketMine не запущен. Сначала введи pmstart."
fi
EOF

chmod +x "$PREFIX/bin/pmstart" "$PREFIX/bin/pmstop" "$PREFIX/bin/pmconsole"
rm -f "$BUNDLE"

echo
echo "Установка завершена."
echo "Запуск:    pmstart"
echo "Консоль:   pmconsole"
echo "Остановка: pmstop"

#!/usr/bin/env bash
set -Eeuo pipefail
PINK='\033[38;5;213m'; RESET='\033[0m'
printf '%b' "$PINK"
cat <<'ART'
⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑
⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐
⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐
⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀
⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇
⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰
⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕
⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵
⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿
⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿
⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿
⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀
ART
printf '%b\n' "$RESET"
printf '%b' "$PINK"; read -r -p "Запустить установку? (Y or N): " answer; printf '%b' "$RESET"
case "$answer" in [Yy]|[Yy][Ee][Ss]) ;; [Nn]|[Nn][Oo]) echo "Установка отменена."; exit 0 ;; *) echo "Введи Y или N."; exit 1 ;; esac

[[ "$(uname -m)" == "x86_64" ]] || { echo "Нужна Ubuntu x86_64."; exit 1; }
grep -qi ubuntu /etc/os-release || { echo "Этот установщик предназначен для Ubuntu."; exit 1; }

ASSET_URL="https://github.com/HookHatai/PocketMine-mob/releases/download/Ubuntu-x64/pocketmine-162dev-ubuntu-x64.tar.gz"
EXPECTED_SHA256="ec391091963e5379acce2624888093ec67bd479ebd875306bbc0a32cef40b3b3"
ARCHIVE="$HOME/pocketmine-162dev-ubuntu-x64.tar.gz"
INSTALL_DIR="$HOME/pocketmine-162dev-ubuntu-x64"
LOCAL_BIN="$HOME/.local/bin"

if [[ -e "$INSTALL_DIR" ]]; then
  echo "Каталог $INSTALL_DIR уже существует. Ничего не перезаписываю."
  exit 1
fi

echo "[1/5] Устанавливаю инструменты..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl tar coreutils tmux

echo "[2/5] Скачиваю архив..."
curl -fL --retry 3 "$ASSET_URL" -o "$ARCHIVE"
echo "$EXPECTED_SHA256  $ARCHIVE" | sha256sum -c -

echo "[3/5] Распаковываю в отдельный каталог..."
mkdir -p "$INSTALL_DIR"
tar -xzf "$ARCHIVE" -C "$INSTALL_DIR"
rm -f "$ARCHIVE"

PHP="$INSTALL_DIR/bin/php7/bin/php"
PHAR="$INSTALL_DIR/PocketMine-MP.phar"
[[ -x "$PHP" && -f "$PHAR" ]] || { echo "Неожиданная структура архива; файлы оставлены в $INSTALL_DIR"; exit 1; }

echo "[4/5] Проверяю PHP и расширения..."
export LD_LIBRARY_PATH="$INSTALL_DIR/bin/php7/lib"
"$PHP" -v | head -n 1
"$PHP" -r 'foreach (["pthreads","yaml","bcmath"] as $e) { if (!extension_loaded($e)) { fwrite(STDERR, "Missing extension: $e\\n"); exit(1); } } echo "pthreads, yaml, bcmath: OK\\n";'

echo "[5/5] Создаю команды управления..."
mkdir -p "$LOCAL_BIN"
cat > "$LOCAL_BIN/pmstart" <<EOF
#!/usr/bin/env bash
set -e
if tmux has-session -t pocketmine-ubuntu 2>/dev/null; then echo "PocketMine уже запущен. Используй pmconsole."; exit 0; fi
tmux new-session -d -s pocketmine-ubuntu "cd '$INSTALL_DIR' && export LD_LIBRARY_PATH='$INSTALL_DIR/bin/php7/lib' && exec '$PHP' '$PHAR'"
sleep 2
tmux has-session -t pocketmine-ubuntu 2>/dev/null && echo "Сервер запущен." || { echo "Сервер завершился. Проверь pmconsole."; exit 1; }
EOF
cat > "$LOCAL_BIN/pmstop" <<'EOF'
#!/usr/bin/env bash
if tmux has-session -t pocketmine-ubuntu 2>/dev/null; then tmux send-keys -t pocketmine-ubuntu "stop" Enter; echo "Команда остановки отправлена."; else echo "PocketMine не запущен."; fi
EOF
cat > "$LOCAL_BIN/pmconsole" <<'EOF'
#!/usr/bin/env bash
if tmux has-session -t pocketmine-ubuntu 2>/dev/null; then tmux attach-session -t pocketmine-ubuntu; else echo "PocketMine не запущен. Сначала введи pmstart."; fi
EOF
chmod +x "$LOCAL_BIN/pmstart" "$LOCAL_BIN/pmstop" "$LOCAL_BIN/pmconsole"
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
  echo 'Добавь ~/.local/bin в PATH:'
  echo 'echo '\''export PATH="$HOME/.local/bin:$PATH"'\'' >> ~/.bashrc && source ~/.bashrc'
fi
echo
echo "Установка завершена. Старая папка ~/pocketmine не затронута."
echo "Новая папка: $INSTALL_DIR"
echo "Команды: pmstart, pmconsole, pmstop"

#!/usr/bin/env bash
set -Eeuo pipefail

PHP="/opt/php72/bin/php"
EXT="/opt/php72/lib/php/extensions/no-debug-zts-20170718"
PHAR="/root/pocketmine/PocketMine-MP.phar"
OUT="/root/pocketmine-162dev-arm64-bundle.tar.gz"

export LD_LIBRARY_PATH="/opt/php72/compat/usr/lib/aarch64-linux-gnu:/opt/php72/lib:${LD_LIBRARY_PATH:-}"

for f in "$PHP" "$EXT/pthreads.so" "$EXT/yaml.so" "$EXT/bcmath.so" "$PHAR"; do
  if [[ ! -e "$f" ]]; then
    echo "ОШИБКА: не найден файл: $f" >&2
    exit 1
  fi
done

echo "Проверка PHP..."
"$PHP" -v | head -n 1
"$PHP" -d "extension=$EXT/pthreads.so" -d "extension=$EXT/yaml.so" -d "extension=$EXT/bcmath.so" -r '
$required = ["pthreads", "yaml", "bcmath"];
$loaded = get_loaded_extensions();
foreach ($required as $name) {
    if (!in_array($name, $loaded, true)) {
        fwrite(STDERR, "Missing extension: $name\n");
        exit(1);
    }
}
echo "Extensions OK: " . implode(", ", $required) . PHP_EOL;
if (bcadd("1", "2") !== "3") {
    fwrite(STDERR, "BCMath test failed\n");
    exit(1);
}
'

echo "Проверка PHAR..."
"$PHP" -r '
$p = new Phar("/root/pocketmine/PocketMine-MP.phar");
echo "PHAR readable; entries: " . count($p) . PHP_EOL;
'

echo "Создание архива..."
tar -czf "$OUT" -C / \
  opt/php72 \
  root/pocketmine/PocketMine-MP.phar

echo "Готово: $OUT"
ls -lh "$OUT"
echo "Архив содержит только проверенную среду PHP и PocketMine PHAR."

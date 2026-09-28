#!/bin/bash
set -e

echo "=== Instalando Flutter SDK para Cloudflare Pages ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
fi

export PATH="$HOME/flutter/bin:$PATH"

echo "=== Verificando Flutter ==="
flutter --version

echo "=== Obteniendo dependencias ==="
flutter pub get

echo "=== Compilando Flutter Web en modo Release ==="
flutter build web --release --base-href /

echo "=== Copiando reglas para Cloudflare Pages ==="
cp web/_redirects build/web/_redirects 2>/dev/null || true
cp web/_headers build/web/_headers 2>/dev/null || true

echo "=== Compilación exitosa en build/web ==="

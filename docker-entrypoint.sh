#!/bin/sh
set -e

echo "🔧 Configurando ambiente..."

if [ "$1" = "php-fpm" ] && [ "$APP_ENV" = "local" ]; then
    cd /var/www/nested

    # Garante permissões corretas para node_modules
    if [ ! -d "node_modules" ]; then
        mkdir -p node_modules
    fi
    chown -R www-data:www-data node_modules

    echo "📦 Instalando dependências npm..."
    # Usa npm ci que é mais rápido que npm install
    if [ -f "package-lock.json" ]; then
        npm ci --no-audit --no-fund
    else
        npm install --no-audit --no-fund
    fi

    # Verifica se precisa gerar o Ziggy
    if [ ! -f "resources/js/ziggy.js" ] || [ "routes/web.php" -nt "resources/js/ziggy.js" ]; then
        echo "🛣️ Gerando rotas do Ziggy..."
        php artisan ziggy:generate resources/js/ziggy.js
    fi

    # Verifica se precisa fazer o build
    if [ ! -d "public/build" ] || [ "package.json" -nt "public/build/manifest.json" ]; then
        echo "🏗️ Gerando build..."
        npm run build
    fi

    echo "🚀 Iniciando Vite development server..."
    node node_modules/.bin/vite --host &
    echo "✅ Vite iniciado em background"

    cd -
fi

exec "$@"
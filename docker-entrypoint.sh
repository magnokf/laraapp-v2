#!/bin/sh
set -e

echo "🔧 Configurando permissões..."

# Create directories if they don't exist
mkdir -p /var/www/nested/storage/framework/{views,cache,sessions}
mkdir -p /var/www/nested/storage/logs
mkdir -p /var/www/nested/bootstrap/cache

# Set permissions for all Laravel directories
find /var/www/nested -type f -exec chmod 644 {} \;
find /var/www/nested -type d -exec chmod 755 {} \;

# Set permissions for storage and bootstrap/cache
chmod -R 775 /var/www/nested/storage
chmod -R 775 /var/www/nested/bootstrap/cache

# Ensure correct ownership
chown -R www-data:www-data /var/www/nested

echo "✅ Permissões configuradas com sucesso!"

# List permissions for debug
echo "📂 Verificando permissões de diretórios críticos:"
ls -la /var/www/nested/public
ls -la /var/www/nested/storage
ls -la /var/www/nested/bootstrap/cache

exec "$@"
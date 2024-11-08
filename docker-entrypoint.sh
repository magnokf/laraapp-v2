#!/bin/sh
set -e

echo "🔧 Configurando permissões..."

# Cria as pastas necessárias para o Laravel e define as permissões corretas
mkdir -p /var/www/nested/storage/framework/{views,cache,sessions}
mkdir -p /var/www/nested/storage/logs
mkdir -p /var/www/nested/bootstrap/cache

# Seta permissões para todos os diretórios do Laravel
find /var/www/nested -type f -exec chmod 644 {} \;
find /var/www/nested -type d -exec chmod 755 {} \;

# Seta permissões para storage e bootstrap/cache
chmod -R 775 /var/www/nested/storage
chmod -R 775 /var/www/nested/bootstrap/cache


# Garante que os arquivos pertencem ao usuário www-data
chown -R www-data:www-data /var/www/nested

echo "✅ Permissões configuradas com sucesso!"

# Verifica as permissoes dos diretorios criticos
echo "📂 Verificando permissões de diretórios críticos:"
ls -la /var/www/nested/public
ls -la /var/www/nested/storage
ls -la /var/www/nested/bootstrap/cache

exec "$@"
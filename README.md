# Laravel em Subpath com Docker

## Objetivo
Implementar uma aplicação Laravel que rode em um subpath (ex: `/laravelapp`) mantendo toda a estrutura padrão do framework, sem necessidade de modificações em rotas, middlewares ou configurações internas do Laravel.

## Benefícios da Implementação
- Manutenção da estrutura padrão do Laravel
- URLs limpas com prefixo consistente
- Isolamento da aplicação em subpath
- Facilidade de manutenção
- Compatibilidade com ferramentas padrão do Laravel

## Stack Tecnológica
- Laravel 11
- PHP 8.3-fpm
- Nginx (Alpine)
- Docker e Docker Compose

## Estrutura do Projeto
```
projeto/
├── Dockerfile                # Configuração do PHP-FPM
├── docker-compose.yml       # Orquestração dos containers
├── docker-entrypoint.sh    # Script de gerenciamento de permissões
├── nginx/
│   └── default.conf        # Configuração do Nginx
└── nested/                 # Aplicação Laravel
```

## Configurações Detalhadas

### 1. Nginx Configuration (nginx/default.conf)
```nginx
server {
    listen 80;
    listen [::]:80;

    server_name _;
    
    index index.php index.html;

    location /laravelapp {
        alias /var/www/nested/public;
        try_files $uri $uri/ @nested;
        
        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass php:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            fastcgi_param PATH_INFO $fastcgi_path_info;
        }
    }

    location @nested {
        rewrite /laravelapp/(.*)$ /laravelapp/index.php?/$1 last;
    }
}
```

Pontos importantes:
- Uso de `alias` em vez de `root` para o subpath
- Configuração correta do `fastcgi_param SCRIPT_FILENAME`
- Rewrite rules para manter URLs amigáveis

### 2. PHP Dockerfile
```dockerfile
FROM php:8.3-fpm-alpine

# ... (instalação de dependências e extensões)

# Configuração de usuário e permissões
RUN usermod -u ${HOST_USER_ID} www-data \
    && groupmod -g ${HOST_GROUP_ID} www-data

# Entrypoint para gestão de permissões
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/www/nested

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
```

### 3. Docker Compose Configuration
```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./nested:/var/www/nested
    depends_on:
      - php

  php:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        HOST_USER_ID: 1000
        HOST_GROUP_ID: 1000
    volumes:
      - ./nested:/var/www/nested
    working_dir: /var/www/nested
```

### 4. Script de Entrypoint
```bash
#!/bin/sh
set -e

echo "🔧 Configurando permissões..."

# Criar diretórios necessários
mkdir -p /var/www/nested/storage/framework/{views,cache,sessions}
mkdir -p /var/www/nested/storage/logs
mkdir -p /var/www/nested/bootstrap/cache

# Configurar permissões
find /var/www/nested -type f -exec chmod 644 {} \;
find /var/www/nested -type d -exec chmod 755 {} \;

chmod -R 775 /var/www/nested/storage
chmod -R 775 /var/www/nested/bootstrap/cache
chown -R www-data:www-data /var/www/nested

exec "$@"
```

## Instalação e Uso

1. **Preparação do Ambiente**
```bash
# Criar estrutura de diretórios
mkdir -p projeto/nginx
cd projeto

# Criar aplicação Laravel
composer create-project laravel/laravel nested
```

2. **Configuração dos Arquivos**
- Copiar as configurações fornecidas para os respectivos arquivos
- Garantir permissões corretas do entrypoint:
```bash
chmod +x docker-entrypoint.sh
```

3. **Inicialização**
```bash
# Construir e iniciar containers
docker-compose build --no-cache
docker-compose up -d
```

4. **Acesso**
- Aplicação: `http://localhost/laravelapp`

## Pontos Importantes

### Segurança
- Permissões de arquivos corretamente configuradas
- Uso de usuário não-root (www-data)
- Configurações PHP otimizadas

### Manutenção
- Estrutura padrão do Laravel mantida
- Fácil atualização de dependências
- Logs acessíveis e organizados

### Performance
- Nginx configurado para servir assets estáticos
- PHP-FPM otimizado
- Cache de opcode habilitado

## Solução de Problemas

### Permissões
Se encontrar problemas de permissão:
```bash
docker-compose exec php sh
ls -la /var/www/nested/storage
ls -la /var/www/nested/bootstrap/cache
```

### Logs
Para verificar logs:
```bash
docker-compose logs -f nginx  # Logs do Nginx
docker-compose logs -f php    # Logs do PHP
```

## Considerações para Produção

1. **SSL/TLS**
- Adicionar certificado SSL
- Configurar redirecionamento HTTPS

2. **Cache**
- Implementar cache de aplicação
- Configurar cache de opcode PHP

3. **Monitoramento**
- Adicionar healthchecks
- Configurar logs de produção

4. **Backup**
- Implementar estratégia de backup
- Configurar persistência de dados

## Conclusão

Esta implementação permite rodar uma aplicação Laravel em subpath mantendo toda a estrutura padrão do framework, facilitando o desenvolvimento e a manutenção. A solução é escalável e pode ser facilmente adaptada para diferentes ambientes e necessidades.
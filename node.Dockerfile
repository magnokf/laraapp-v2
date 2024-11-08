FROM node:alpine

ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=1000

# Criar usuário node com UID/GID específicos
RUN deluser --remove-home node \
    && addgroup -g ${HOST_GROUP_ID} node \
    && adduser -u ${HOST_USER_ID} -G node -s /bin/sh -D node

# Definir diretório de trabalho
WORKDIR /var/www/nested

# Mudar para o usuário node
USER node

# Comando padrão
CMD ["npm", "run", "dev", "--", "--host"]
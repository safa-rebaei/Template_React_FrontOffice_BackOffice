# Étape 1: Build de l'application React
FROM node:18-alpine AS build

# Définir le registre npm
RUN npm config set registry https://registry.npmjs.org/

WORKDIR /app

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances avec retry
RUN npm install --legacy-peer-deps \
    --fetch-retries=5 \
    --fetch-timeout=120000

# Copier tout le code source
COPY . .

# Build l'application React
RUN npm run build

# Étape 2: Serveur web
FROM nginx:alpine

# Copier les fichiers buildés de React vers Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Copier une configuration Nginx personnalisée (optionnel)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
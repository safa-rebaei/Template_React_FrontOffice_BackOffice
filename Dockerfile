# Utilisez Node 18+ au lieu de 16 (plus récent et mieux supporté)
FROM node:18-alpine AS build

# Définir le registre npm en global dans l'image
RUN npm config set registry https://registry.npmjs.org/

WORKDIR /app

# Copier d'abord les fichiers de dépendances
COPY package.json package-lock.json* ./

# Installer avec retry et timeout augmenté
RUN npm install --legacy-peer-deps \
    --fetch-retries=5 \
    --fetch-retry-factor=2 \
    --fetch-retry-mintimeout=10000 \
    --fetch-retry-maxtimeout=60000 \
    --fetch-timeout=120000

# Copier le reste du code
COPY . .

# Build l'application React
RUN npm run build

# Étape de production
FROM nginx:alpine

# Copier les fichiers buildés
COPY --from=build /app/build /usr/share/nginx/html

# Copier une configuration nginx personnalisée si nécessaire
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
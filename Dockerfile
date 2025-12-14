# ===== Build React =====
FROM node:16-alpine AS build

WORKDIR /app

# Copier les fichiers de dépendances
COPY package.json package-lock.json* ./

# Installer les dépendances avec timeout et registry
RUN npm install --legacy-peer-deps --fetch-timeout=60000 --registry=https://registry.npmjs.org/

# Copier le reste du code
COPY . .

# Builder l'application
RUN npm run build

# ===== Serve avec Nginx =====
FROM nginx:1.25-alpine

# Copier le build React dans le dossier Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Exposer le port 80
EXPOSE 80

# Lancer Nginx en avant-plan
CMD ["nginx", "-g", "daemon off;"]

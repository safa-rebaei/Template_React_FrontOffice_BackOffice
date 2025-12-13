# Étape 1 : build
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Étape 2 : lancer l'app avec le serveur Node pour test
# (optionnel, sinon juste pour build)
RUN npm install -g serve
CMD ["serve", "-s", "build", "-l", "80"]

# ===== Build React (Node compatible avec react-scripts 4) =====
FROM node:14-alpine AS build

WORKDIR /app

COPY package.json ./

RUN npm install --legacy-peer-deps

COPY . .

RUN npm run build

# ===== Serve avec Nginx =====
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

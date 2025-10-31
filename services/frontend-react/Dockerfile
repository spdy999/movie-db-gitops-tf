# Stage 1: build React app
FROM node:20-alpine as builder
WORKDIR /app
COPY package*.json ./

# If lock file is missing or out of sync, fallback to install
RUN if [ -f package-lock.json ]; then npm ci || npm install; else npm install; fi

COPY . .
RUN npm run build

# Stage 2: serve with Nginx
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
# Custom proxy for backend
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

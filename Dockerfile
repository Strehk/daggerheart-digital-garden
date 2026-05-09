# syntax=docker/dockerfile:1.7

# ---- builder ----
FROM node:22-alpine AS builder

WORKDIR /app

# Install dependencies first for better layer caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the source (including .env, which holds non-secret config)
COPY . .

# Eleventy build needs network access to fetch the theme (get-theme.js)
RUN npm run build

# ---- runtime ----
FROM nginx:alpine AS runtime

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# Tiny healthcheck against the index page
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget -q -O /dev/null http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

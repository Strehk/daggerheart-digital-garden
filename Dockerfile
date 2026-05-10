# syntax=docker/dockerfile:1.7

# ---- builder ----
FROM node:22-alpine AS builder

WORKDIR /app

# Install dependencies first for better layer caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the source. Configuration lives entirely in the
# committed .env — edit and push to change site name, theme, flags, etc.
COPY . .

RUN npm run build

# ---- runtime ----
FROM nginx:alpine AS runtime

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Clear the base image's default html (welcome page, 50x.html) so it
# doesn't leak through when the build output lacks a matching file.
RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# curl (without -f) exits 0 on any HTTP response, so the healthcheck
# passes even before a home note is configured (root would 404/403).
# We only want to verify nginx is alive and serving HTTP, not that any
# specific page exists yet.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -sS -o /dev/null --connect-timeout 2 http://127.0.0.1/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

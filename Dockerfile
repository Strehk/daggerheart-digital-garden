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

# DEBUG — visible in Dokploy build logs. Remove once everything is green.
RUN echo "===== [1] final .env =====" && cat .env && echo "" && echo "===== end ====="

# Verify build environment can reach the theme URL (network egress).
# wget exits 0 on any successful HTTP response.
RUN echo "===== [2] theme URL reachable? =====" && \
    THEME_URL=$(grep '^THEME=' .env | cut -d= -f2-) && \
    if [ -n "$THEME_URL" ]; then \
      wget -q -S --spider "$THEME_URL" 2>&1 | head -5 || echo "FETCH FAILED"; \
    else \
      echo "no THEME set in .env"; \
    fi && \
    echo "===== end ====="

RUN npm run build

RUN echo "===== [3] dist/styles/ contents =====" && ls -la dist/styles/ && \
    echo "" && echo "===== [4] _theme.*.css present? =====" && \
    (ls dist/styles/_theme.*.css 2>&1 || echo "NO THEME CSS — get-theme.js did not produce one") && \
    echo "" && echo "===== [5] theme reference in built HTML =====" && \
    (grep -E 'theme.*\.css|theme-' dist/index.html 2>/dev/null | head -5 || echo "no dist/index.html") && \
    echo "===== end ====="

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

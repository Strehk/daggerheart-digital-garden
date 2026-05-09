# syntax=docker/dockerfile:1.7

# ---- builder ----
FROM node:22-alpine AS builder

WORKDIR /app

# Build-time configuration — pass these as Build Arguments in Dokploy
# (or `docker build --build-arg KEY=value ...`). Anything left unset
# falls back to the value committed in `.env`.
#
# Why we mutate `.env` instead of declaring ENVs: dotenv.config() does
# not override existing process.env, so an empty ENV from an unset ARG
# would silently mask the .env default. We instead rewrite .env at
# build time, keeping it the single source of truth.
ARG SITE_NAME_HEADER
ARG SITE_BASE_URL
ARG SITE_MAIN_LANGUAGE
ARG BASE_THEME
ARG THEME
ARG SHOW_CREATED_TIMESTAMP
ARG SHOW_UPDATED_TIMESTAMP
ARG TIMESTAMP_FORMAT
ARG USE_FULL_RESOLUTION_IMAGES

# Install dependencies first for better layer caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the source.
COPY . .

# For each non-empty build arg, replace (or append) the matching line in .env.
RUN set -e; \
    apply_arg() { \
      key="$1"; val="$2"; \
      [ -z "$val" ] && return 0; \
      if grep -q "^${key}=" .env 2>/dev/null; then \
        awk -v k="$key" -v v="$val" -F= 'BEGIN{OFS="="} $1==k{print k"="v; next} 1' .env > .env.tmp && mv .env.tmp .env; \
      else \
        printf '%s=%s\n' "$key" "$val" >> .env; \
      fi; \
    }; \
    apply_arg SITE_NAME_HEADER "$SITE_NAME_HEADER"; \
    apply_arg SITE_BASE_URL "$SITE_BASE_URL"; \
    apply_arg SITE_MAIN_LANGUAGE "$SITE_MAIN_LANGUAGE"; \
    apply_arg BASE_THEME "$BASE_THEME"; \
    apply_arg THEME "$THEME"; \
    apply_arg SHOW_CREATED_TIMESTAMP "$SHOW_CREATED_TIMESTAMP"; \
    apply_arg SHOW_UPDATED_TIMESTAMP "$SHOW_UPDATED_TIMESTAMP"; \
    apply_arg TIMESTAMP_FORMAT "$TIMESTAMP_FORMAT"; \
    apply_arg USE_FULL_RESOLUTION_IMAGES "$USE_FULL_RESOLUTION_IMAGES"

# Eleventy build needs network access to fetch the theme (get-theme.js)
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

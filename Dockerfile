# syntax=docker/dockerfile:1.7

# ---- builder ----
FROM node:22-alpine AS builder

WORKDIR /app

# Build-time configuration — pass these as Build Arguments in Dokploy
# (or `docker build --build-arg KEY=value ...`). Defaults fall back to
# whatever upstream `.env` ships. dotenv does not override existing
# process.env, so ENVs declared here win over `.env`.
ARG SITE_NAME_HEADER
ARG SITE_BASE_URL
ARG SITE_MAIN_LANGUAGE
ARG BASE_THEME
ARG THEME
ARG SHOW_CREATED_TIMESTAMP
ARG SHOW_UPDATED_TIMESTAMP
ARG TIMESTAMP_FORMAT
ARG USE_FULL_RESOLUTION_IMAGES

ENV SITE_NAME_HEADER=${SITE_NAME_HEADER}
ENV SITE_BASE_URL=${SITE_BASE_URL}
ENV SITE_MAIN_LANGUAGE=${SITE_MAIN_LANGUAGE}
ENV BASE_THEME=${BASE_THEME}
ENV THEME=${THEME}
ENV SHOW_CREATED_TIMESTAMP=${SHOW_CREATED_TIMESTAMP}
ENV SHOW_UPDATED_TIMESTAMP=${SHOW_UPDATED_TIMESTAMP}
ENV TIMESTAMP_FORMAT=${TIMESTAMP_FORMAT}
ENV USE_FULL_RESOLUTION_IMAGES=${USE_FULL_RESOLUTION_IMAGES}

# Install dependencies first for better layer caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the source. Upstream `.env` provides defaults for any
# build arg left unset above.
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

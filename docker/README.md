# Selfhost via Docker

Multi-stage Build: Stage 1 baut den statischen Eleventy-Output, Stage 2 serviert ihn mit nginx.

## Build & Run

```sh
docker compose build
docker compose up -d
# → http://127.0.0.1:8080
```

Vor einem Rebuild bei Bedarf `.env` anpassen (Theme, `SITE_BASE_URL`, Feature-Flags). Die Werte werden zur Build-Zeit ausgewertet, also ist nach Änderung ein `docker compose build` nötig.

## Reverse Proxy davor (Caddy-Beispiel)

```caddy
garden.example.tld {
    basicauth {
        party JDJhJDEy...   # via `caddy hash-password`
    }
    reverse_proxy 127.0.0.1:8080
}
```

## Update-Workflow

```sh
git pull                     # neue Notes/Theme/Code
docker compose build         # rebuild image
docker compose up -d         # rolling restart
```

Als Cron oder GitHub-Webhook automatisierbar.

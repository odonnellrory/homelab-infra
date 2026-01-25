# homelab-infra

This repository contains the Docker Compose stacks that power my Raspberry Pi homelab.

Current services include:

- **Bitwarden (Bitwarden Lite)** – local password manager
- **Pi-hole** – local DNS + ad blocking

The goal of this repo is to keep a clean, version-controlled “source of truth” for my home services, so I can rebuild or migrate to another device quickly.

---

## Repository layout

```
stacks/
  bitwarden/
    docker-compose.yml
    Caddyfile
    settings.env.example
  pihole/
    docker-compose.yml
    README.md
.gitignore

```

---

## Requirements

On the Raspberry Pi host:

- Docker
- Docker Compose plugin (docker compose)
- Local DNS

---

## Updating

To pull newer images and restart a stack:

```
docker compose pull
docker compose up -d

```



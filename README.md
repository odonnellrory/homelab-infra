# homelab-infra

This repository contains the Docker Compose stacks that power my Raspberry Pi homelab.

The goal is to keep a clean, version-controlled “source of truth” for my home services so I can rebuild or migrate to another host quickly.

This repo intentionally **does not** contain persistent application data (databases, configs, secrets).  
That data lives in a separate folder on the host: `~/homelab-data/`.

---

## Current services

- **Bitwarden (Bitwarden Lite)** — local password manager
- **Pi-hole** — local DNS + ad blocking
- **Caddy** — reverse proxy + internal TLS (`*.home.arpa`)
- **Homarr** — dashboard for services
- **Uptime Kuma** — monitoring + uptime checks

---

## Repository layout

```
.
├── .env
├── .gitignore
├── README.md
└── stacks
    ├── bitwarden
    │   ├── docker-compose.yml
    │   └── settings.env.example
    ├── caddy
    │   ├── Caddyfile
    │   └── docker-compose.yml
    ├── homarr
    │   └── docker-compose.yml
    ├── pihole
    │   ├── docker-compose.yml
    │   └── README.md
    └── uptime-kuma
        └── docker-compose.yml

7 directories, 11 files

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

## Installation Guide

To do.

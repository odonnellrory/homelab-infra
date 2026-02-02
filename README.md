# homelab-infra

This repository contains the Docker Compose stacks that power my Raspberry Pi homelab.

The goal is to keep a clean, version-controlled “source of truth” for my home services so I can rebuild or migrate to another host quickly.

This repo intentionally **does not** contain persistent application data (databases, configs, secrets).
That data lives in a separate folder on the host: `~/homelab-data/`.

---

## Current services

- **Actual Budget** — self-hosted budgeting app
- **Bitwarden (Bitwarden Lite)** — local password manager
- **Pi-hole** — local DNS + ad blocking
- **Caddy** — reverse proxy + internal TLS (`*.home.arpa`)
- **Glance** — dashboard / start page
- **Uptime Kuma** — monitoring + uptime checks

---

## Repository layout

```
.
├── README.md
└── stacks
    ├── actual
    │   └── docker-compose.yml
    ├── bitwarden
    │   ├── docker-compose.yml
    │   └── settings.env.example
    ├── caddy
    │   ├── Caddyfile
    │   └── docker-compose.yml
    ├── glance
    │   └── docker-compose.yml
    ├── pihole
    │   ├── docker-compose.yml
    │   └── README.md
    └── uptime-kuma
        └── docker-compose.yml

8 directories, 10 files

```

---

## Requirements

On the Raspberry Pi host:

- Docker
- Docker Compose plugin (`docker compose`)

---

## Environment + data model

### Single root `.env`
This repo uses a **single** `.env` file at the repository root (`./.env`) for shared variables like:

- `HOMELAB_DATA=...`
- `TZ=...`

Most stacks reference `${HOMELAB_DATA}` so persistent data stays out of the repo.

### Persistent data lives outside the repo
All persistent volumes should live under:

```
${HOMELAB_DATA}

```

Example:

```

~/homelab-data/actual
~/homelab-data/uptime-kuma
...

````

---

## Running stacks

Because the `.env` file is at the repo root, run Compose with `--env-file .env`.

For me, this looks like this:

```
docker compose --env-file ../../.env up -d

```

---

## Reverse proxy + DNS

* **Pi-hole** provides DNS records like `service.home.arpa` for the Raspberry Pi IP
* **Caddy** reverse proxies those hostnames to the relevant service containers
* Internal TLS is handled by Caddy for `*.home.arpa`

---

## Installation guide

To do.

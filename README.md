# homelab-infra

Infrastructure for the Raspberry Pi services and reverse-proxy layer in my homelab.

This repository contains the Docker Compose definitions I use to operate the Raspberry Pi, together with the Caddy configuration that provides internal TLS and reverse proxying to services elsewhere in the homelab.

---

## Security

This is real infrastructure.

For that reason, the public repository intentionally excludes environment-specific and sensitive values such as:

- live IP addresses
- internal hostnames
- credentials and installation keys
- persistent application data
- machine-specific filesystem paths
- other operational secrets

These values are supplied through an ignored root `.env` file and other service-specific configuration outside the repository.

A sanitized `.env.example` is provided to document the required configuration variables.

The tracked Caddyfile uses Caddy environment-variable substitution:

```caddy
{$SERVICE_URL} {
    tls internal
    reverse_proxy http://{$BACKEND_HOST}:{$BACKEND_PORT}
}
```

Docker Compose passes the required values from the private `.env` file into the Caddy container.

This keeps the actual routing and proxy configuration version-controlled while preventing the public repository from becoming a map of the live network.

---

## Services

### Raspberry Pi workloads

The Pi currently hosts the following containerized services:

| Service | Purpose |
| --- | --- |
| Pi-hole | Local DNS and network-level filtering |
| Bitwarden Lite | Self-hosted password management |
| Glance | Homelab dashboard and start page |
| Uptime Kuma | Service availability monitoring |
| Actual Budget | Self-hosted personal budgeting |
| Caddy | Reverse proxy and internal TLS |

Caddy also provides internal HTTPS entry points for selected services hosted elsewhere in the homelab, including virtualization, storage, media, document management and AI workloads.

Internal services use hostnames rather than requiring users to remember IP addresses and ports.

Caddy provides the routing layer and, where configured, internal TLS.

---

## Repository layout

```text
.
├── .env.example
├── .gitignore
├── README.md
├── scripts
│   └── deploy.sh
└── stacks
    ├── actual
    │   └── docker-compose.yml
    ├── bitwarden
    │   ├── docker-compose.yml
    │   └── settings.env.example
    ├── caddy
    │   ├── Caddyfile
    │   └── docker-compose.yml
    ├── glance
    │   └── docker-compose.yml
    ├── pihole
    │   ├── docker-compose.yml
    │   └── README.md
    └── uptime-kuma
        └── docker-compose.yml
```

Persistent application data is deliberately kept outside the repository.

---

## Requirements

The host requires:

- Linux
- Docker Engine
- Docker Compose plugin
- access to the relevant local networks
- a configured root `.env` file

Check Docker and Compose with:

```bash
docker --version
docker compose version
```

---

## Environment configuration

Copy the example environment file:

```bash
cp .env.example .env
```

Then edit:

```bash
nano .env
```

The real `.env` file is ignored by Git.

It contains two broad categories of configuration.

### Shared settings

For example:

```bash
HOMELAB_DATA=/srv/homelab-data
TZ=Etc/UTC
```

`HOMELAB_DATA` defines the location used for persistent service data.

### Network

Backend hosts, service names and ports are also supplied through the environment.

For example:

```bash
TNAS_HOST=192.168.0.30
TNAS_URL=nas.example.internal
TNAS_HTTPS_PORT=8000
```

The values in `.env.example` use documentation-safe example addresses and are not the values used by the live environment.

---

## Persistent data model

Application data is not stored in this repository.

```text
${HOMELAB_DATA}/
├── actual/
├── bitwarden/
├── glance/
├── pihole/
└── uptime-kuma/
```

This separation means the Git repository describes how services are deployed without containing their databases, user content or credentials.

---

## Deploying the stack

I have included a helper script for the docker services included in this repo.

```bash
./scripts/deploy.sh
```

---

## Managing services

Show service status:

```bash
./scripts/deploy.sh status
```

Pull updated images:

```bash
./scripts/deploy.sh pull
```

Restart all services:

```bash
./scripts/deploy.sh restart
```

Manage a single stack:

```bash
./scripts/deploy.sh deploy caddy
```

Multiple stacks can also be supplied:

```bash
./scripts/deploy.sh restart pihole caddy
```

Stop the managed stacks:

```bash
./scripts/deploy.sh stop
```

---

## Manual Compose usage

Each stack can also be managed directly.

For example:

```bash
cd stacks/uptime-kuma

docker compose \
    --env-file ../../.env \
    up -d
```

The root `.env` is explicitly supplied because Compose files live in separate stack directories.

---

## Reverse proxy and internal DNS

Pi-hole provides local DNS resolution for service names.

Caddy receives requests for those names and proxies them to the appropriate backend.

The public repository does not contain the live addressing information. Instead, the Caddyfile references environment variables such as:

```caddy
reverse_proxy http://{$AI_SERVER_HOST}:{$SILLYTAVERN_PORT}
```

The values are injected into the Caddy container by Docker Compose.

This design keeps routing behaviour visible and auditable in Git while keeping the live topology outside public version control.

---

## Updating

The deployment helper can pull and redeploy services:

```bash
./scripts/deploy.sh pull
./scripts/deploy.sh
```

Changes should be validated before being applied:

```bash
./scripts/deploy.sh validate
```

---


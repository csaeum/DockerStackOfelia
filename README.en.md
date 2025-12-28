# Docker Ofelia Stack

[![GitHub Release](https://img.shields.io/github/v/release/csaeum/DockerStackOfelia)](https://github.com/csaeum/DockerStackOfelia/releases)
[![License](https://img.shields.io/badge/License-GPL--3.0--or--later-blue.svg)](LICENSE)

🇩🇪 [Deutsch](README.md) | 🇫🇷 [Français](README.fr.md)

A production-ready Docker stack for [Ofelia](https://github.com/mcuadros/ofelia) - a modern cron job scheduler for Docker containers with integrated logrotate functionality.

## What is Ofelia?

Ofelia is a Docker job scheduler that enables running cron jobs directly in Docker containers. Instead of running a separate cron daemon in each container, Ofelia centrally manages all time-based tasks via Docker labels.

## Features

- Central management of all cron jobs for Docker containers
- Automatic log rotation with configurable schedule
- Secure configuration (Docker socket read-only)
- Timezone support (Europe/Berlin)
- Job logging in separate directory
- Production-ready with restart policy

## Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- Access to `/var/run/docker.sock`

## Installation

1. Clone repository:
```bash
git clone https://github.com/csaeum/DockerStackOfelia.git
cd DockerStackOfelia
```

2. Adjust environment variables (optional):
```bash
cp .env.example .env
nano .env
```

3. Start stack:
```bash
docker-compose up -d
```

## Configuration

### Environment Variables (.env)

```bash
COMPOSE_PROJECT_NAME=ofelia      # Prefix for container names
TIMEZONE=Europe/Berlin            # Timezone for cron jobs
```

### Define Cron Jobs in Other Containers

Add labels to your Docker containers to define cron jobs:

```yaml
services:
  myapp:
    image: myapp:latest
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.backup.schedule: "0 2 * * *"
      ofelia.job-exec.backup.command: "/app/backup.sh"
```

#### Job Types

- **job-exec**: Execute command in running container
- **job-run**: Execute command in new container (deleted afterwards)
- **job-local**: Execute command on host

#### Schedule Format

- Cron format: `0 2 * * *` (daily at 2 AM)
- Go format: `@every 5m` (every 5 minutes)
- Shortcuts: `@hourly`, `@daily`, `@weekly`, `@monthly`

### Logrotate Configuration

The logrotate configuration is located in `config/logrotate.conf`:

```
/ofelia/logs/*.log {
    daily
    rotate 2
    missingok
    notifempty
    compress
    delaycompress
    copytruncate
}
```

Customizations:
- `rotate 2`: Number of log files to keep
- `daily`: Rotation interval (daily, weekly, monthly)
- `compress`: Compress logs after rotation

## Usage

### Stack Commands

```bash
# Start stack
docker-compose up -d

# Show logs
docker-compose logs -f ofelia

# Stop stack
docker-compose down

# Restart stack
docker-compose restart
```

### Check Job Status

```bash
# Show Ofelia logs
docker logs ofelia

# Job logs in logs directory
tail -f logs/*.log
```

### Manual Log Rotation

```bash
docker exec ofelia-logrotate logrotate /etc/logrotate.conf
```

## Directory Structure

```
.
├── config/
│   └── logrotate.conf          # Logrotate configuration
├── logs/                        # Job logs (created automatically)
├── .env                         # Environment variables
├── docker-compose.yaml          # Docker Compose configuration
├── Dockerfile                   # Logrotate container image
└── README.md                    # This file
```

## Security

- Docker socket mounted read-only (`:ro`)
- No root privileges required
- Logs stored in separate volume
- No sensitive data in container images

## Troubleshooting

### Jobs Not Running

1. Container running?
```bash
docker ps | grep ofelia
```

2. Labels set correctly?
```bash
docker inspect <container-name> | grep ofelia
```

3. Check Ofelia logs:
```bash
docker logs ofelia
```

### Log Rotation Not Working

1. Logrotate container running?
```bash
docker ps | grep logrotate
```

2. Test manually:
```bash
docker exec ofelia-logrotate logrotate -d /etc/logrotate.conf
```

## Examples

### Daily Backup

```yaml
services:
  database:
    image: postgres:15
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.db-backup.schedule: "0 3 * * *"
      ofelia.job-exec.db-backup.command: "pg_dump -U postgres mydb > /backup/dump.sql"
```

### Log Cleanup Every 6 Hours

```yaml
services:
  webapp:
    image: nginx:alpine
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.cleanup.schedule: "@every 6h"
      ofelia.job-exec.cleanup.command: "find /var/log -name '*.log' -mtime +7 -delete"
```

## License & Support

This project is open source (GPL-3.0-or-later) and free. If it helped you, I'd appreciate your support:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/csaeum)
[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-ea4aaa?style=for-the-badge&logo=github-sponsors&logoColor=white)](https://github.com/sponsors/csaeum)
[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/csaeum)

**Made with ❤️ by WSC - Web SEO Consulting**

## Credits

- [Ofelia](https://github.com/mcuadros/ofelia) by mcuadros
- Alpine Linux for minimal container images

## Contributing

Pull requests are welcome! For major changes, please open an issue first.

## Links

- [Ofelia Documentation](https://github.com/mcuadros/ofelia)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Logrotate Documentation](https://linux.die.net/man/8/logrotate)

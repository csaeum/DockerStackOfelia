# Docker Ofelia Stack

[![GitHub Release](https://img.shields.io/github/v/release/csaeum/DockerStackOfelia)](https://github.com/csaeum/DockerStackOfelia/releases)
[![License](https://img.shields.io/badge/License-GPL--3.0--or--later-blue.svg)](LICENSE)

🇬🇧 [English](README.en.md) | 🇫🇷 [Français](README.fr.md)

Ein produktionsbereiter Docker Stack für [Ofelia](https://github.com/mcuadros/ofelia) - einen modernen Cron-Job-Scheduler für Docker-Container mit integrierter Logrotate-Funktionalität.

## Was ist Ofelia?

Ofelia ist ein Docker-Job-Scheduler, der es ermöglicht, Cron-Jobs direkt in Docker-Containern auszuführen. Statt in jedem Container einen eigenen Cron-Daemon laufen zu lassen, verwaltet Ofelia zentral alle zeitgesteuerten Aufgaben über Docker-Labels.

## Features

- Zentrale Verwaltung aller Cron-Jobs für Docker-Container
- Automatische Logrotation mit konfiguriertem Zeitplan
- Sichere Konfiguration (Docker Socket read-only)
- Timezone-Unterstützung (Europe/Berlin)
- Job-Logging in separatem Verzeichnis
- Produktionsbereit mit Restart-Policy

## Voraussetzungen

- Docker Engine 20.10+
- Docker Compose 2.0+
- Zugriff auf `/var/run/docker.sock`

## Installation

1. Repository klonen:
```bash
git clone https://github.com/csaeum/DockerStackOfelia.git
cd DockerStackOfelia
```

2. Umgebungsvariablen anpassen (optional):
```bash
cp .env.example .env
nano .env
```

3. Stack starten:
```bash
docker-compose up -d
```

## Konfiguration

### Umgebungsvariablen (.env)

```bash
COMPOSE_PROJECT_NAME=ofelia      # Präfix für Container-Namen
TIMEZONE=Europe/Berlin            # Timezone für Cron-Jobs
```

### Cron-Jobs in anderen Containern definieren

Fügen Sie Labels zu Ihren Docker-Containern hinzu, um Cron-Jobs zu definieren:

```yaml
services:
  myapp:
    image: myapp:latest
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.backup.schedule: "0 2 * * *"
      ofelia.job-exec.backup.command: "/app/backup.sh"
```

#### Job-Typen

- **job-exec**: Befehl in laufendem Container ausführen
- **job-run**: Befehl in neuem Container (wird danach gelöscht)
- **job-local**: Befehl auf dem Host ausführen

#### Schedule-Format

- Cron-Format: `0 2 * * *` (täglich um 2 Uhr)
- Go-Format: `@every 5m` (alle 5 Minuten)
- Shortcuts: `@hourly`, `@daily`, `@weekly`, `@monthly`

### Logrotate-Konfiguration

Die Logrotate-Konfiguration befindet sich in `config/logrotate.conf`:

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

Anpassungen:
- `rotate 2`: Anzahl der aufzubewahrenden Log-Dateien
- `daily`: Rotationsintervall (daily, weekly, monthly)
- `compress`: Logs nach Rotation komprimieren

## Nutzung

### Stack-Befehle

```bash
# Stack starten
docker-compose up -d

# Logs anzeigen
docker-compose logs -f ofelia

# Stack stoppen
docker-compose down

# Stack neu starten
docker-compose restart
```

### Job-Status prüfen

```bash
# Ofelia-Logs anzeigen
docker logs ofelia

# Job-Logs im logs-Verzeichnis
tail -f logs/*.log
```

### Manuelle Logrotation

```bash
docker exec ofelia-logrotate logrotate /etc/logrotate.conf
```

## Verzeichnisstruktur

```
.
├── config/
│   └── logrotate.conf          # Logrotate-Konfiguration
├── logs/                        # Job-Logs (automatisch erstellt)
├── .env                         # Umgebungsvariablen
├── docker-compose.yaml          # Docker Compose Konfiguration
├── Dockerfile                   # Logrotate-Container Image
└── README.md                    # Diese Datei
```

## Sicherheit

- Docker Socket ist read-only gemountet (`:ro`)
- Keine Root-Rechte erforderlich
- Logs werden in separatem Volume gespeichert
- Keine sensiblen Daten in den Container-Images

## Troubleshooting

### Jobs werden nicht ausgeführt

1. Container läuft?
```bash
docker ps | grep ofelia
```

2. Labels korrekt gesetzt?
```bash
docker inspect <container-name> | grep ofelia
```

3. Ofelia-Logs prüfen:
```bash
docker logs ofelia
```

### Logrotation funktioniert nicht

1. Logrotate-Container läuft?
```bash
docker ps | grep logrotate
```

2. Manuell testen:
```bash
docker exec ofelia-logrotate logrotate -d /etc/logrotate.conf
```

## Beispiele

### Tägliches Backup

```yaml
services:
  database:
    image: postgres:15
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.db-backup.schedule: "0 3 * * *"
      ofelia.job-exec.db-backup.command: "pg_dump -U postgres mydb > /backup/dump.sql"
```

### Log-Bereinigung alle 6 Stunden

```yaml
services:
  webapp:
    image: nginx:alpine
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.cleanup.schedule: "@every 6h"
      ofelia.job-exec.cleanup.command: "find /var/log -name '*.log' -mtime +7 -delete"
```

## Lizenz & Unterstützung

Dieses Projekt ist Open Source (GPL-3.0-or-later) und kostenlos. Wenn es dir geholfen hat, freue ich mich über deine Unterstützung:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/csaeum)
[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-ea4aaa?style=for-the-badge&logo=github-sponsors&logoColor=white)](https://github.com/sponsors/csaeum)
[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/csaeum)

**Made with ❤️ by WSC - Web SEO Consulting**

## Credits

- [Ofelia](https://github.com/mcuadros/ofelia) by mcuadros
- Alpine Linux für minimale Container-Images

## Beitragen

Pull Requests sind willkommen! Für größere Änderungen öffne bitte zuerst ein Issue.

## Links

- [Ofelia Dokumentation](https://github.com/mcuadros/ofelia)
- [Docker Compose Referenz](https://docs.docker.com/compose/)
- [Logrotate Dokumentation](https://linux.die.net/man/8/logrotate)

# Docker Ofelia Stack

[![GitHub Release](https://img.shields.io/github/v/release/csaeum/DockerStackOfelia)](https://github.com/csaeum/DockerStackOfelia/releases)
[![License](https://img.shields.io/badge/License-GPL--3.0--or--later-blue.svg)](LICENSE)

🇩🇪 [Deutsch](README.md) | 🇬🇧 [English](README.en.md)

Une stack Docker prête pour la production pour [Ofelia](https://github.com/mcuadros/ofelia) - un planificateur de tâches cron moderne pour conteneurs Docker avec fonctionnalité logrotate intégrée.

## Qu'est-ce qu'Ofelia?

Ofelia est un planificateur de tâches Docker qui permet d'exécuter des tâches cron directement dans les conteneurs Docker. Au lieu d'exécuter un démon cron séparé dans chaque conteneur, Ofelia gère centralement toutes les tâches planifiées via les labels Docker.

## Fonctionnalités

- Gestion centralisée de toutes les tâches cron pour les conteneurs Docker
- Rotation automatique des logs avec planification configurable
- Configuration sécurisée (socket Docker en lecture seule)
- Support des fuseaux horaires (Europe/Berlin)
- Journalisation des tâches dans un répertoire séparé
- Prêt pour la production avec politique de redémarrage

## Prérequis

- Docker Engine 20.10+
- Docker Compose 2.0+
- Accès à `/var/run/docker.sock`

## Installation

1. Cloner le dépôt:
```bash
git clone https://github.com/csaeum/DockerStackOfelia.git
cd DockerStackOfelia
```

2. Ajuster les variables d'environnement (optionnel):
```bash
cp .env.example .env
nano .env
```

3. Démarrer la stack:
```bash
docker-compose up -d
```

## Configuration

### Variables d'environnement (.env)

```bash
COMPOSE_PROJECT_NAME=ofelia      # Préfixe pour les noms de conteneurs
TIMEZONE=Europe/Berlin            # Fuseau horaire pour les tâches cron
```

### Définir des tâches Cron dans d'autres conteneurs

Ajoutez des labels à vos conteneurs Docker pour définir des tâches cron:

```yaml
services:
  myapp:
    image: myapp:latest
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.backup.schedule: "0 2 * * *"
      ofelia.job-exec.backup.command: "/app/backup.sh"
```

#### Types de tâches

- **job-exec**: Exécuter une commande dans un conteneur en cours d'exécution
- **job-run**: Exécuter une commande dans un nouveau conteneur (supprimé après)
- **job-local**: Exécuter une commande sur l'hôte

#### Format de planification

- Format cron: `0 2 * * *` (quotidien à 2h du matin)
- Format Go: `@every 5m` (toutes les 5 minutes)
- Raccourcis: `@hourly`, `@daily`, `@weekly`, `@monthly`

### Configuration de Logrotate

La configuration de logrotate se trouve dans `config/logrotate.conf`:

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

Personnalisations:
- `rotate 2`: Nombre de fichiers logs à conserver
- `daily`: Intervalle de rotation (daily, weekly, monthly)
- `compress`: Compresser les logs après rotation

## Utilisation

### Commandes de la stack

```bash
# Démarrer la stack
docker-compose up -d

# Afficher les logs
docker-compose logs -f ofelia

# Arrêter la stack
docker-compose down

# Redémarrer la stack
docker-compose restart
```

### Vérifier l'état des tâches

```bash
# Afficher les logs d'Ofelia
docker logs ofelia

# Logs des tâches dans le répertoire logs
tail -f logs/*.log
```

### Rotation manuelle des logs

```bash
docker exec ofelia-logrotate logrotate /etc/logrotate.conf
```

## Structure des répertoires

```
.
├── config/
│   └── logrotate.conf          # Configuration de logrotate
├── logs/                        # Logs des tâches (créé automatiquement)
├── .env                         # Variables d'environnement
├── docker-compose.yaml          # Configuration Docker Compose
├── Dockerfile                   # Image du conteneur logrotate
└── README.md                    # Ce fichier
```

## Sécurité

- Socket Docker monté en lecture seule (`:ro`)
- Aucun privilège root requis
- Logs stockés dans un volume séparé
- Aucune donnée sensible dans les images de conteneurs

## Dépannage

### Les tâches ne s'exécutent pas

1. Le conteneur est-il en cours d'exécution?
```bash
docker ps | grep ofelia
```

2. Les labels sont-ils correctement définis?
```bash
docker inspect <container-name> | grep ofelia
```

3. Vérifier les logs d'Ofelia:
```bash
docker logs ofelia
```

### La rotation des logs ne fonctionne pas

1. Le conteneur logrotate est-il en cours d'exécution?
```bash
docker ps | grep logrotate
```

2. Tester manuellement:
```bash
docker exec ofelia-logrotate logrotate -d /etc/logrotate.conf
```

## Exemples

### Sauvegarde quotidienne

```yaml
services:
  database:
    image: postgres:15
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.db-backup.schedule: "0 3 * * *"
      ofelia.job-exec.db-backup.command: "pg_dump -U postgres mydb > /backup/dump.sql"
```

### Nettoyage des logs toutes les 6 heures

```yaml
services:
  webapp:
    image: nginx:alpine
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.cleanup.schedule: "@every 6h"
      ofelia.job-exec.cleanup.command: "find /var/log -name '*.log' -mtime +7 -delete"
```

## Licence & Support

Ce projet est open source (GPL-3.0-or-later) et gratuit. S'il vous a aidé, j'apprécierais votre soutien:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/csaeum)
[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-ea4aaa?style=for-the-badge&logo=github-sponsors&logoColor=white)](https://github.com/sponsors/csaeum)
[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/csaeum)

**Made with ❤️ by WSC - Web SEO Consulting**

## Crédits

- [Ofelia](https://github.com/mcuadros/ofelia) par mcuadros
- Alpine Linux pour des images de conteneurs minimales

## Contribuer

Les pull requests sont les bienvenues! Pour les modifications majeures, veuillez d'abord ouvrir une issue.

## Liens

- [Documentation Ofelia](https://github.com/mcuadros/ofelia)
- [Référence Docker Compose](https://docs.docker.com/compose/)
- [Documentation Logrotate](https://linux.die.net/man/8/logrotate)

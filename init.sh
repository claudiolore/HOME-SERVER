#!/bin/bash
# init.sh - Crea cartelle e imposta permessi per tutti i servizi
# Esegui con: sudo ./init.sh

set -e

echo "Creazione cartelle..."

# Database (gestiscono i permessi da soli, ma creiamo le cartelle)
mkdir -p postgres/data
mkdir -p postgres-apps/data
mkdir -p postgres-apps/init
mkdir -p mysql/data
mkdir -p redis/data

# AI
mkdir -p ollama/data
mkdir -p qdrant/data
mkdir -p open-webui/data

# Cloud
mkdir -p nextcloud/data
mkdir -p immich/upload
mkdir -p immich/ml-cache

# Monitoring
mkdir -p prometheus/config
mkdir -p prometheus/data
mkdir -p grafana/data
mkdir -p uptime-kuma/data

# Gestione
mkdir -p portainer/data
mkdir -p homepage/config

# Sicurezza
mkdir -p vaultwarden/data

# Networking
mkdir -p upsnap/data

# Produttività
mkdir -p n8n/data
mkdir -p vikunja/data
mkdir -p homarr/configs homarr/icons homarr/data

echo "Impostazione permessi..."

# Prometheus - UID 65534 (nobody)
chown -R 65534:65534 prometheus/data

# Grafana - UID 472
chown -R 472:472 grafana/data

# Nextcloud - UID 33 (www-data)
chown -R 33:33 nextcloud/data

# Qdrant - UID 1000
chown -R 1000:1000 qdrant/data

# Uptime Kuma - UID 1000
chown -R 1000:1000 uptime-kuma/data

# MySQL - UID 999
chown -R 999:999 mysql/data

# Immich - UID 1000
chown -R 1000:1000 immich/upload
chown -R 1000:1000 immich/ml-cache

# Redis - UID 999
chown -R 999:999 redis/data

# Upsnap - UID 1000
chown -R 1000:1000 upsnap/data

# N8n - UID 1000 (node user)
chown -R 1000:1000 n8n/data

# Vikunja - UID 1000
chown -R 1000:1000 vikunja/data

echo "Permessi impostati correttamente!"
echo ""
echo "Ora puoi avviare i servizi con:"
echo "  docker compose up -d"

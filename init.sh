#!/bin/bash
# init.sh - Crea cartelle e imposta permessi per tutti i servizi
# Esegui con: sudo ./init.sh

set -e

echo "Creazione cartelle..."

# Database (gestiscono i permessi da soli, ma creiamo le cartelle)
mkdir -p postgres/data
mkdir -p mysql/data
mkdir -p redis/data

# AI
mkdir -p ollama/data
mkdir -p qdrant/data
mkdir -p open-webui/data

# Cloud
mkdir -p nextcloud/data

# Monitoring
mkdir -p prometheus/config
mkdir -p prometheus/data
mkdir -p grafana/data
mkdir -p uptime-kuma/data

# Gestione
mkdir -p portainer/data
mkdir -p homepage/config

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

# Redis - UID 999
chown -R 999:999 redis/data

echo "Permessi impostati correttamente!"
echo ""
echo "Ora puoi avviare i servizi con:"
echo "  docker compose up -d"

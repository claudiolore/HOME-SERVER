# Guida Test Home Server

Sostituisci `RASPBERRY_IP` con l'IP del tuo Raspberry Pi (es. `192.168.1.100`).

---

## Riepilogo Credenziali

### Servizi con credenziali dal `.env`

| Servizio | Username | Password |
|----------|----------|----------|
| **Nextcloud** | `NEXTCLOUD_ADMIN_USER` | `NEXTCLOUD_ADMIN_PASSWORD` |
| **Grafana** | `GRAFANA_ADMIN_USER` | `GRAFANA_ADMIN_PASSWORD` |
| **PostgreSQL** | `POSTGRES_USER` | `POSTGRES_PASSWORD` |
| **MySQL (root)** | `root` | `MYSQL_ROOT_PASSWORD` |
| **MySQL (app)** | `MYSQL_USER` | `MYSQL_PASSWORD` |
| **Redis** | - | `REDIS_PASSWORD` |
| **Vaultwarden** | - | `VAULTWARDEN_ADMIN_TOKEN` (per `/admin`) |

### Servizi con account da creare al primo accesso

| Servizio | Note |
|----------|------|
| **Portainer** | Crea admin entro 5 minuti dal primo avvio |
| **Uptime Kuma** | Crea account al primo accesso |
| **Open WebUI** | Registra un account al primo accesso |
| **Vaultwarden** | Crea account dal client Bitwarden o dall'interfaccia web |

### Servizi senza autenticazione

| Servizio | Note |
|----------|------|
| **Homepage** | Dashboard pubblica |
| **Prometheus** | Metriche accessibili direttamente |
| **Dozzle** | Log viewer senza login |
| **Traefik** | Dashboard accessibile senza login |

---

## Setup Completo (da zero)

```bash
# 1. Clona il repository
git clone <repo>
cd HOME-SERVER

# 2. Configura le variabili d'ambiente
cp .env.example .env
nano .env  # modifica le password

# 3. Installa tool utili
sudo apt install -y jq

# 4. Inizializza cartelle e permessi
sudo ./init.sh

# 5. Avvia tutti i servizi
docker compose up -d
```

---

## Prerequisiti

```bash
# Installa jq per parsare output JSON (usato nei test)
sudo apt install -y jq
```

---

## 1. Verifica Rapida Stato Container

```bash
# Tutti i container devono essere "Up" e "healthy"
docker ps --format "table {{.Names}}\t{{.Status}}"

# Verifica nessun container in restart loop
docker ps -a --filter "status=restarting"
```

---

## 2. Test Servizi Web (da browser)

| Servizio | URL | Autenticazione | Credenziali |
|----------|-----|----------------|-------------|
| **Portainer** | `http://RASPBERRY_IP:9000` | Crea account | Scegli username/password al primo accesso |
| **Homepage** | `http://RASPBERRY_IP:3002` | Nessuna | Accesso diretto |
| **Nextcloud** | `http://RASPBERRY_IP:8080` | Da .env | `NEXTCLOUD_ADMIN_USER` / `NEXTCLOUD_ADMIN_PASSWORD` |
| **Grafana** | `http://RASPBERRY_IP:3000` | Da .env | `GRAFANA_ADMIN_USER` / `GRAFANA_ADMIN_PASSWORD` |
| **Prometheus** | `http://RASPBERRY_IP:9090` | Nessuna | Accesso diretto |
| **Uptime Kuma** | `http://RASPBERRY_IP:3001` | Crea account | Scegli username/password al primo accesso |
| **Dozzle** | `http://RASPBERRY_IP:8888` | Nessuna | Accesso diretto |
| **Open WebUI** | `http://RASPBERRY_IP:8081` | Crea account | Registra un account al primo accesso |
| **Traefik** | `http://RASPBERRY_IP:8082` | Nessuna | Dashboard accessibile direttamente |
| **Vaultwarden** | `http://RASPBERRY_IP:8222` | Crea account | Registra dal client Bitwarden |
| **Vaultwarden Admin** | `http://RASPBERRY_IP:8222/admin` | Da .env | `VAULTWARDEN_ADMIN_TOKEN` |

---

## 3. Test Database (da CLI sul Raspberry)

### Riepilogo Credenziali Database (tutte dal `.env`)

| Database | Variabile User | Variabile Password |
|----------|----------------|-------------------|
| PostgreSQL | `POSTGRES_USER` | `POSTGRES_PASSWORD` |
| MySQL (root) | root | `MYSQL_ROOT_PASSWORD` |
| MySQL (app) | `MYSQL_USER` | `MYSQL_PASSWORD` |
| Redis | - | `REDIS_PASSWORD` |

### PostgreSQL

```bash
# Sostituisci 'devuser' con il valore di POSTGRES_USER dal .env
docker exec -it postgres psql -U devuser -c "SELECT version();"
```

### MySQL

```bash
# Come root (usa MYSQL_ROOT_PASSWORD)
docker exec -it mysql mysql -u root -p -e "SHOW DATABASES;"

# Come utente app (usa MYSQL_USER e MYSQL_PASSWORD)
docker exec -it mysql mysql -u nextcloud_user -p -e "SHOW DATABASES;"
```

### Redis

```bash
# Sostituisci con il valore di REDIS_PASSWORD dal .env
docker exec -it redis redis-cli -a "TUA_REDIS_PASSWORD" PING
# Deve rispondere: PONG

# Oppure leggi la password automaticamente:
docker exec -it redis redis-cli -a $(grep REDIS_PASSWORD ~/HOME-SERVER/.env | cut -d'=' -f2) PING
```

---

## 4. Test AI Stack

### Ollama

```bash
# Verifica che Ollama risponda
curl http://RASPBERRY_IP:11434/api/tags

# Scarica un modello leggero per test
docker exec -it ollama ollama pull tinyllama

# Test generazione
curl http://RASPBERRY_IP:11434/api/generate -d '{
  "model": "tinyllama",
  "prompt": "Ciao, come stai?",
  "stream": false
}'
```

### Qdrant

```bash
curl http://RASPBERRY_IP:6333/collections
# Deve rispondere: {"result":{"collections":[]},"status":"ok","time":...}
```

### Open WebUI

Dopo aver scaricato un modello con Ollama:

1. Vai su `http://RASPBERRY_IP:8081`
2. Registra un account
3. Seleziona il modello (es. tinyllama)
4. Scrivi un messaggio e verifica la risposta

---

## 5. Test Monitoring

### Prometheus

```bash
# Richiede jq (vedi Prerequisiti)
curl http://RASPBERRY_IP:9090/api/v1/targets | jq '.data.activeTargets[].health'
# Tutti i target devono essere "up"

# Alternativa senza jq:
curl -s http://RASPBERRY_IP:9090/api/v1/targets | grep -o '"health":"[^"]*"'
```

### Grafana

1. Login su `http://RASPBERRY_IP:3000`
   - **Username:** valore di `GRAFANA_ADMIN_USER` dal `.env` (default: `admin`)
   - **Password:** valore di `GRAFANA_ADMIN_PASSWORD` dal `.env`
2. Vai su **Connections → Data Sources → Add data source**
3. Seleziona **Prometheus**
4. URL: `http://prometheus:9090`
5. Click **Save & Test** → deve dire "Data source is working"

---

## 6. Test Nextcloud (Setup Completo)

Al primo accesso su `http://RASPBERRY_IP:8080`:

### Configurazione Iniziale

1. **Crea account amministratore**:
   - Username: scegli un nome (es. `admin`)
   - Password: scegli una password sicura

2. **Data folder**: lascia il valore di default `/var/www/html/data`

3. **Database - IMPORTANTE: Seleziona MySQL/MariaDB** (NON SQLite!):
   - Clicca su **MySQL/MariaDB**
   - **Database user**: valore di `NEXTCLOUD_MYSQL_USER` dal `.env`
   - **Database password**: valore di `NEXTCLOUD_MYSQL_PASSWORD` dal `.env`
   - **Database name**: valore di `NEXTCLOUD_MYSQL_DATABASE` dal `.env`
   - **Database host**: `mysql`

4. Clicca **Install**

### Verifica credenziali database

```bash
# Visualizza le credenziali MySQL per Nextcloud
cat .env | grep NEXTCLOUD_MYSQL
```

### Errore "Can't write into config directory"

Se appare questo errore, sistema i permessi:

```bash
sudo chown -R 33:33 nextcloud/data
docker compose restart nextcloud
```

### Configura Redis (opzionale, migliora le performance)

Dopo l'installazione, in Impostazioni → Amministrazione:
- Host: `redis`
- Porta: `6379`
- Password: valore di `REDIS_PASSWORD` dal `.env`

---

## 7. Test Networking

### Traefik

```bash
# Verifica che la dashboard Traefik risponda
curl -s http://RASPBERRY_IP:8082/api/overview | jq '.http'

# Verifica che Traefik veda i provider Docker
curl -s http://RASPBERRY_IP:8082/api/providers | jq '.'

# Alternativa senza jq:
curl -s http://RASPBERRY_IP:8082/api/overview
# Deve rispondere con un JSON contenente info su entrypoints e routers
```

---

## 8. Test Sicurezza

### Vaultwarden

```bash
# Verifica che Vaultwarden risponda
curl -s http://RASPBERRY_IP:8222/ | head -5
# Deve rispondere con HTML della pagina di login

# Verifica che il pannello admin sia accessibile
curl -s -o /dev/null -w "%{http_code}" http://RASPBERRY_IP:8222/admin
# Deve rispondere: 200
```

**Setup:**
1. Vai su `http://RASPBERRY_IP:8222`
2. Crea un account con email e master password
3. Installa l'estensione browser Bitwarden
4. Nelle impostazioni dell'estensione, imposta il server URL: `http://RASPBERRY_IP:8222`
5. Effettua il login con l'account creato

**Admin Panel:**
1. Vai su `http://RASPBERRY_IP:8222/admin`
2. Inserisci il `VAULTWARDEN_ADMIN_TOKEN` dal `.env`
3. Verifica che la dashboard admin si carichi correttamente

---

## 9. Checklist Finale

```bash
# Verifica memoria e CPU
docker stats --no-stream

# Verifica spazio disco
df -h

# Verifica log per errori
docker logs nextcloud 2>&1 | tail -20
docker logs grafana 2>&1 | tail -20
docker logs open-webui 2>&1 | tail -20
docker logs traefik 2>&1 | tail -20
docker logs vaultwarden 2>&1 | tail -20
```

---

## Troubleshooting

### Container in restart loop con "permission denied"

Se vedi errori tipo `permission denied` o `not writable` nei log, riesegui lo script di init:

```bash
sudo ./init.sh
docker compose restart NOME_CONTAINER
```

Oppure sistema manualmente i permessi per il servizio specifico:

| Servizio | UID | Comando |
|----------|-----|---------|
| Prometheus | 65534 | `sudo chown -R 65534:65534 prometheus/data` |
| Grafana | 472 | `sudo chown -R 472:472 grafana/data` |
| Nextcloud | 33 | `sudo chown -R 33:33 nextcloud/data` |
| Qdrant | 1000 | `sudo chown -R 1000:1000 qdrant/data` |
| Uptime Kuma | 1000 | `sudo chown -R 1000:1000 uptime-kuma/data` |
| Redis | 999 | `sudo chown -R 999:999 redis/data` |

### Servizio non risponde

```bash
# Controlla i log
docker logs NOME_CONTAINER

# Riavvia singolo container
docker restart NOME_CONTAINER

# Riavvia tutto
docker compose down && docker compose up -d
```

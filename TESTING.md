# Guida Test Home Server

Sostituisci `RASPBERRY_IP` con l'IP del tuo Raspberry Pi (es. `192.168.1.100`).

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

| Servizio | URL | Cosa verificare |
|----------|-----|-----------------|
| **Portainer** | `http://RASPBERRY_IP:9000` | Crea admin account al primo accesso |
| **Homepage** | `http://RASPBERRY_IP:3002` | Dashboard con tutti i servizi |
| **Nextcloud** | `http://RASPBERRY_IP:8080` | Wizard setup iniziale |
| **Grafana** | `http://RASPBERRY_IP:3000` | Login: admin/admin (cambierà) |
| **Prometheus** | `http://RASPBERRY_IP:9090` | Vai su Status → Targets |
| **Uptime Kuma** | `http://RASPBERRY_IP:3001` | Crea account e aggiungi monitor |
| **Dozzle** | `http://RASPBERRY_IP:8888` | Vedi log live dei container |
| **Open WebUI** | `http://RASPBERRY_IP:8081` | Interfaccia chat AI |

---

## 3. Test Database (da CLI sul Raspberry)

### PostgreSQL

```bash
# Usa l'utente definito in .env (POSTGRES_USER, default: devuser)
docker exec -it postgres psql -U devuser -c "SELECT version();"
```

### MySQL

```bash
docker exec -it mysql mysql -u root -p -e "SHOW DATABASES;"
# Inserisci la password MYSQL_ROOT_PASSWORD dal .env
```

### Redis

```bash
# Redis richiede autenticazione (password dal .env)
docker exec -it redis redis-cli -a $(grep REDIS_PASSWORD ~/HOME-SERVER/.env | cut -d'=' -f2) PING
# Deve rispondere: PONG
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

1. Login su `http://RASPBERRY_IP:3000` (admin/admin)
2. Vai su **Connections → Data Sources → Add data source**
3. Seleziona **Prometheus**
4. URL: `http://prometheus:9090`
5. Click **Save & Test** → deve dire "Data source is working"

---

## 6. Test Nextcloud (Setup Completo)

Al primo accesso su `http://RASPBERRY_IP:8080`:

1. **Crea account admin** (scegli username/password)
2. **Configura database MySQL:**
   - Utente: `nextcloud`
   - Password: (dal .env `MYSQL_PASSWORD`)
   - Database: `nextcloud`
   - Host: `mysql:3306`
3. **Configura Redis** (opzionale, nelle impostazioni avanzate):
   - Host: `redis`
   - Porta: `6379`
   - Password: (dal .env `REDIS_PASSWORD`)

---

## 7. Test Watchtower (Monitor-Only Mode)

Watchtower è configurato in **modalità monitor-only**: controlla se ci sono aggiornamenti disponibili e invia notifiche, ma **non applica automaticamente gli aggiornamenti**. Questo ti permette di decidere quando aggiornare.

### Verifica stato container

```bash
# Controlla che Watchtower sia in esecuzione
docker ps --filter "name=watchtower" --format "table {{.Names}}\t{{.Status}}"

# Verifica i log per vedere l'attività di Watchtower
docker logs watchtower --tail 20
```

### Verifica configurazione

```bash
# Controlla le variabili d'ambiente attive
docker inspect watchtower | jq '.[0].Config.Env'

# Verifica che sia in monitor-only mode
docker inspect watchtower | jq '.[0].Config.Env[] | select(startswith("WATCHTOWER_MONITOR"))'
# Output atteso: "WATCHTOWER_MONITOR_ONLY=true"
```

### Forzare un controllo immediato

```bash
# Controlla subito gli aggiornamenti disponibili (senza applicarli)
docker exec watchtower /watchtower --run-once
```

### Aggiornare manualmente i servizi

Quando Watchtower ti notifica che ci sono aggiornamenti disponibili:

```bash
# Aggiorna un singolo servizio
docker compose pull <nome-servizio>
docker compose up -d <nome-servizio>

# Esempio: aggiornare Grafana
docker compose pull grafana
docker compose up -d grafana

# Aggiorna TUTTI i servizi
docker compose pull
docker compose up -d

# Pulizia immagini vecchie dopo gli aggiornamenti
docker image prune -f
```

### Verifica notifiche email

```bash
# Controlla che le notifiche siano configurate
docker logs watchtower | grep -i "shoutrrr\|notification"
# Output atteso: "Using shoutrrr" invece di "Using no notifications"
```

### Monitoraggio tramite log

```bash
# Segui i log in tempo reale
docker logs -f watchtower

# Esempio output quando trova aggiornamenti disponibili (monitor-only):
# time="..." level=info msg="Found new image" image="grafana/grafana:latest"
# time="..." level=info msg="Session done" Failed=0 Scanned=N Updated=0 duration=...
# (Updated=0 perché in monitor-only non applica gli aggiornamenti)
```

### Troubleshooting notifiche

Se le notifiche email non funzionano:

```bash
# Verifica le variabili SMTP nel .env
grep WATCHTOWER_SMTP ~/HOME-SERVER/.env

# Controlla i log per errori di notifica
docker logs watchtower 2>&1 | grep -i "error\|notification\|smtp"
```

---

## 8. Checklist Finale

```bash
# Verifica memoria e CPU
docker stats --no-stream

# Verifica spazio disco
df -h

# Verifica log per errori
docker logs nextcloud 2>&1 | tail -20
docker logs grafana 2>&1 | tail -20
docker logs open-webui 2>&1 | tail -20
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

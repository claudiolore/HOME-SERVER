# Guida Test Home Server

Sostituisci `RASPBERRY_IP` con l'IP del tuo Raspberry Pi (es. `192.168.1.100`).

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
docker exec -it postgres psql -U postgres -c "SELECT version();"
```

### MySQL

```bash
docker exec -it mysql mysql -u root -p -e "SHOW DATABASES;"
# Inserisci la password MYSQL_ROOT_PASSWORD dal .env
```

### Redis

```bash
docker exec -it redis redis-cli PING
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
curl http://RASPBERRY_IP:9090/api/v1/targets | jq '.data.activeTargets[].health'
# Tutti i target devono essere "up"
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

## 7. Checklist Finale

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

Se un servizio non risponde:

```bash
# Controlla i log
docker logs NOME_CONTAINER

# Riavvia singolo container
docker restart NOME_CONTAINER

# Riavvia tutto
docker compose down && docker compose up -d
```

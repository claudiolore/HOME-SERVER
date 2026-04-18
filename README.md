# Home Server

Documentazione dei servizi attualmente implementati nel `docker-compose.yml`.

---

## Quick Start

```bash
# 1. Crea .env
cp .env.example .env
nano .env  # modifica le password

# 2. Installa tool utili per test e debug
sudo apt install -y jq

# 3. Inizializza cartelle e permessi
sudo ./init.sh

# 4. Avvia tutto
docker compose up -d
```

---

## Database

### PostgreSQL 16 — Dev (`postgres`)

- **Container:** `postgres`
- **Porta:** `5432`
- **Immagine:** `postgres:16`
- **Dati:** `./postgres/data`

Server PostgreSQL dedicato allo sviluppo. Completamente vuoto, da usare liberamente per progetti e applicazioni in sviluppo. Non condivide dati con i servizi dell'home server.

**Domanda a cui risponde:** *"Mi serve un PostgreSQL pulito per sviluppare la mia app."*

---

### PostgreSQL 16 + pgvector — App (`postgres-apps`)

- **Container:** `postgres-apps`
- **Porta:** `5433`
- **Immagine:** `pgvector/pgvector:pg16`
- **Dati:** `./postgres-apps/data`
- **Init:** `./postgres-apps/init/`

Server PostgreSQL dedicato ai servizi dell'home server (Nextcloud e Immich). All'avvio crea automaticamente utenti e database isolati per ciascun servizio. Include l'estensione `pgvector` richiesta da Immich.

| Servizio | Utente | Database |
|----------|--------|----------|
| Nextcloud | `NEXTCLOUD_DB_USER` | `nextcloud` |
| Immich | `IMMICH_DB_USER` | `immich` |

**Domanda a cui risponde:** *"Voglio che i database dei miei servizi siano isolati da quelli di sviluppo."*

---

### MySQL 8 — Dev (`mysql`)

- **Container:** `mysql`
- **Porta:** `3306`
- **Immagine:** `mysql:8`
- **Dati:** `./mysql/data`

Server MySQL dedicato allo sviluppo. Completamente vuoto, da usare liberamente per progetti e applicazioni in sviluppo. Non condivide dati con i servizi dell'home server.

**Domanda a cui risponde:** *"Mi serve un MySQL pulito per sviluppare la mia app."*

---

### Redis 7

- **Container:** `redis`
- **Porta:** `6379`
- **Immagine:** `redis:7-alpine`
- **Dati:** `./redis/data`

Store chiave-valore in memoria, usato come cache e session store. Serve a Nextcloud per velocizzare il file locking e la gestione delle sessioni. Protetto da password.

**Domanda a cui risponde:** *"Mi serve una cache veloce per migliorare le performance dei miei servizi."*

---

## AI

### Ollama

- **Container:** `ollama`
- **Porta:** `11434`
- **Immagine:** `ollama/ollama:latest`
- **Dati:** `./ollama/data`

Runtime per eseguire Large Language Models (LLM) in locale. Permette di scaricare e usare modelli come Llama, Mistral, Gemma e altri direttamente sul server, senza inviare dati a servizi cloud. Espone un'API REST compatibile con il formato OpenAI.

**Domanda a cui risponde:** *"Voglio eseguire modelli AI in locale, mantenendo i miei dati privati e senza costi per API."*

---

### Qdrant

- **Container:** `qdrant`
- **Porte:** `6333` (HTTP/REST), `6334` (gRPC)
- **Immagine:** `y0mg/qdrant-raspberry-pi` (community build per RPi 5)
- **Dati:** `./qdrant/data`

Database vettoriale ottimizzato per la ricerca per similarità. Usato in combinazione con Ollama per implementare pipeline RAG (Retrieval-Augmented Generation): si indicizzano documenti come embedding vettoriali e si recuperano i più rilevanti per arricchire il contesto dei prompt AI.

> **Nota RPi 5:** l'immagine ufficiale `qdrant/qdrant` crasha su Raspberry Pi 5 per un bug jemalloc con kernel a 16KB page size. Si usa `y0mg/qdrant-raspberry-pi` che risolve il problema.

**Domanda a cui risponde:** *"Voglio fare ricerca semantica sui miei documenti e dare memoria ai miei modelli AI."*

---

### Open WebUI

- **Container:** `open-webui`
- **Porta:** `8081`
- **Immagine:** `ghcr.io/open-webui/open-webui:main`
- **Dati:** `./open-webui/data`
- **Dipendenze:** Ollama

Interfaccia web per interagire con Ollama, simile a ChatGPT ma completamente locale. Supporta conversazioni multiple, gestione modelli, upload documenti e cronologia chat. Si connette automaticamente a Ollama sulla rete interna.

**Domanda a cui risponde:** *"Voglio chattare con i miei modelli AI da browser, come su ChatGPT."*

---

### FalkorDB

- **Container:** `falkordb`
- **Porte:** `6379` (Redis protocol), `3003` (Web UI)
- **Immagine:** `falkordb/falkordb:latest`
- **Dati:** `./falkordb/data`

Database a grafo che usa il protocollo Redis. Interfaccia web integrata per eseguire query Cypher e visualizzare il grafo. Usato per gestire Knowledge Graph e dati relazionali complessi in ambito AI.

> **Nota RPi 5:** l'immagine potrebbe non supportare ARM64. Testare sulla Raspberry Pi 5 — se non funziona, potrebbe servire un build custom.

**Domanda a cui risponde:** *"Voglio un database a grafo per gestire knowledge graph e query Cypher."*

---

## Cloud Personale

### Nextcloud

- **Container:** `nextcloud`
- **Porta:** `8080`
- **Immagine:** `nextcloud:latest`
- **Dati:** `./nextcloud/data`
- **Dipendenze:** `postgres-apps`, Redis

Piattaforma self-hosted per la gestione di file, calendario, contatti, note e collaborazione. Alternativa a Google Drive / Dropbox completamente sotto il proprio controllo. Utilizza PostgreSQL (`postgres-apps`) come database e Redis come cache per le performance.

**Domanda a cui risponde:** *"Voglio un cloud personale per sincronizzare file, calendari e contatti senza affidarmi a servizi terzi."*

---

## Media / Utilità

### Immich

- **Container:** `immich-server`, `immich-machine-learning`
- **Porta:** `2283`
- **Immagini:** `ghcr.io/immich-app/immich-server:release`, `ghcr.io/immich-app/immich-machine-learning:release`
- **Dati:** `./immich/upload`, `./immich/ml-cache`
- **Dipendenze:** `postgres-apps`, Redis

Piattaforma self-hosted per la gestione e il backup di foto e video, alternativa a Google Photos. Supporta riconoscimento facciale, ricerca semantica e organizzazione automatica tramite machine learning. Usa il database `immich` su `postgres-apps` (con estensione `pgvector`).

**Domanda a cui risponde:** *"Voglio fare il backup delle mie foto in locale con riconoscimento automatico."*

---

### Homepage

- **Container:** `homepage`
- **Porta:** `3002`
- **Immagine:** `ghcr.io/gethomepage/homepage:latest`
- **Config:** `./homepage/config`

Dashboard personale con link a tutti i servizi del server. Mostra widget con informazioni rapide (stato servizi, meteo, ecc.). Configurazione via file YAML, integrazione Docker per discovery automatico dei container.

**Domanda a cui risponde:** *"Dove trovo tutti i miei servizi in un'unica pagina?"*

---

## Gestione Container

### Portainer

- **Container:** `portainer`
- **Porta:** `9000`
- **Immagine:** `portainer/portainer-ce:latest`
- **Dati:** `./portainer/data`

UI web per controllare Docker: start/stop/restart container, vedere volumi, reti, immagini. Permette di creare e modificare container senza toccare la CLI, visualizzare log, eseguire comandi dentro un container e gestire stack compose.

**Domanda a cui risponde:** *"Voglio gestire i container da browser, senza usare la CLI."*

---

## Networking

### Upsnap

- **Container:** `upsnap`
- **Porta:** `8090`
- **Immagine:** `ghcr.io/seriousm4x/upsnap:latest`
- **Dati:** `./upsnap/data`
- **Network:** `host` (necessario per Wake-on-LAN)

Applicazione web per Wake-on-LAN. Permette di accendere dispositivi sulla rete locale inviando magic packets. Supporta ping per verificare lo stato dei dispositivi, scheduling per accensioni programmate e gruppi di dispositivi.

**Domanda a cui risponde:** *"Voglio accendere i miei PC e dispositivi da remoto con un click."*

---

### Traefik

- **Container:** `traefik`
- **Porte:** `80` (HTTP), `443` (HTTPS), `8082` (Dashboard)
- **Immagine:** `traefik:v3.0`

Reverse proxy e load balancer moderno per Docker. Supporta auto-discovery dei container tramite labels, certificati HTTPS automatici con Let's Encrypt, e routing intelligente. Al momento è configurato in modalità base con la dashboard abilitata, pronto per essere attivato come proxy per gli altri servizi in futuro.

**Domanda a cui risponde:** *"Voglio un punto di ingresso unico per tutti i miei servizi, con HTTPS automatico."*

---

## Sicurezza

### Vaultwarden

- **Container:** `vaultwarden`
- **Porta:** `8222`
- **Immagine:** `vaultwarden/server`
- **Dati:** `./vaultwarden/data`

Implementazione leggera e self-hosted del server Bitwarden. Permette di gestire password, note sicure, carte di credito e identità. Compatibile con tutte le app client Bitwarden (browser, mobile, desktop). Il pannello admin è accessibile su `/admin` con il token configurato nel `.env`.

**Domanda a cui risponde:** *"Voglio gestire le mie password in modo sicuro senza affidarmi a servizi cloud."*

---

## Monitoring

### Uptime Kuma

- **Container:** `uptime-kuma`
- **Porta:** `3001`
- **Immagine:** `louislam/uptime-kuma:latest`
- **Dati:** `./uptime-kuma/data`

Monitoraggio uptime dei servizi con controlli HTTP, ping e TCP. Invia notifiche se qualcosa va giù (Telegram, email, Discord). Dashboard con storico disponibilità e tempi di risposta.

**Domanda a cui risponde:** *"È tutto online? Avvisami se qualcosa crasha."*

---

### Prometheus

- **Container:** `prometheus`
- **Porta:** `9090`
- **Immagine:** `prom/prometheus:latest`
- **Config:** `./prometheus/config`
- **Dati:** `./prometheus/data`

Sistema di raccolta e storage di metriche time-series. Scrape periodico degli endpoint dei servizi per raccogliere dati su CPU, RAM, disco, richieste HTTP e altre metriche. Backend dati per Grafana.

**Domanda a cui risponde:** *"Voglio raccogliere e conservare metriche dei miei servizi nel tempo."*

---

### Grafana

- **Container:** `grafana`
- **Porta:** `3000`
- **Immagine:** `grafana/grafana:latest`
- **Dati:** `./grafana/data`
- **Dipendenze:** Prometheus

Piattaforma di visualizzazione dati con dashboard grafiche. Si collega a Prometheus per mostrare metriche in tempo reale e trend storici. Supporta alert e notifiche configurabili.

**Domanda a cui risponde:** *"Quanta RAM usa Postgres? C'è un trend nel tempo?"*

---

### Dozzle

- **Container:** `dozzle`
- **Porta:** `8888`
- **Immagine:** `amir20/dozzle:latest`

Log viewer in tempo reale per tutti i container Docker. Interfaccia web leggera che mostra i log senza bisogno di accedere al terminale. Non persiste dati — mostra solo log live.

**Domanda a cui risponde:** *"Cosa stanno loggando i container adesso?"*

---

## Produttività

### n8n

- **Container:** `n8n`
- **Porta:** `5678`
- **Immagine:** `n8nio/n8n:latest`
- **Dati:** `./n8n/data`

Piattaforma di automazione workflow no-code/low-code. Permette di collegare servizi, automatizzare task ripetitivi e creare pipeline dati tramite un'interfaccia visuale a nodi.

**Domanda a cui risponde:** *"Voglio automatizzare task e collegare servizi senza scrivere codice."*

---

### Vikunja

- **Container:** `vikunja`
- **Porta:** `3456`
- **Immagine:** `vikunja/vikunja:latest`
- **Dati:** `./vikunja/data`

Gestione task e progetti self-hosted, alternativa a Todoist/Trello. Supporta liste, kanban, date di scadenza e condivisione.

**Domanda a cui risponde:** *"Voglio gestire le mie attività in modo privato senza app cloud."*

---

## Rete

Tutti i servizi comunicano attraverso una rete Docker interna (`internal`, driver bridge). Le porte sono esposte direttamente sull'host. Traefik è presente come reverse proxy in modalità base, pronto per essere configurato come punto di ingresso unico in futuro. L'accesso remoto avviene tramite Tailscale installato nativamente sull'host.

---

## Variabili D'ambiente e Configurazione

- Le credenziali sono gestite tramite variabili d'ambiente nel file `.env`
- Prometheus richiede un file di configurazione in `./prometheus/config/prometheus.yml`
- Tailscale è installato nativamente sull'host (non in Docker) per massima affidabilità
- Vaultwarden richiede un admin token per il pannello di amministrazione (`/admin`)
- `postgres-apps` crea automaticamente utenti e database per Nextcloud e Immich tramite `./postgres-apps/init/01-init.sh`

-------------

# Future Improvements

## Infrastruttura / Networking

- **Traefik routing completo** — configurare labels sui servizi esistenti per routing tramite Traefik con HTTPS automatico (Let's Encrypt)

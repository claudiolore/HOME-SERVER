# Servizi Attivi — Home Server

Documentazione dei servizi attualmente implementati nel `docker-compose.yml`.

---

## Database

### PostgreSQL 16

- **Container:** `postgres`
- **Porta:** `5432`
- **Immagine:** `postgres:16`
- **Dati:** `./postgres/data`

Database relazionale avanzato, ideale per applicazioni che richiedono integrità dei dati, query complesse e supporto JSON nativo. Usato come database di riferimento per progetti che necessitano di un motore SQL completo e affidabile.

**Domanda a cui risponde:** *"Mi serve un database relazionale robusto, con supporto a transazioni, JSON e query avanzate."*

---

### MySQL 8

- **Container:** `mysql`
- **Porta:** `3306`
- **Immagine:** `mysql:8`
- **Dati:** `./mysql/data`

Database relazionale ampiamente diffuso, usato in questo stack come backend per Nextcloud. Compatibile con la maggior parte delle applicazioni web e CMS.

**Domanda a cui risponde:** *"Ho bisogno di un database MySQL compatibile con Nextcloud e altre app web tradizionali."*

---

### Redis 7

- **Container:** `redis`
- **Porta:** `6379`
- **Immagine:** `redis:7-alpine`
- **Dati:** `./redis/data`

Store chiave-valore in memoria, usato come cache e session store. In questo stack serve a Nextcloud per velocizzare il file locking e la gestione delle sessioni. Protetto da password.

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
- **Immagine:** `qdrant/qdrant:latest`
- **Dati:** `./qdrant/data`

Database vettoriale ottimizzato per la ricerca per similarità. Usato in combinazione con Ollama per implementare pipeline RAG (Retrieval-Augmented Generation): si indicizzano documenti come embedding vettoriali e si recuperano i più rilevanti per arricchire il contesto dei prompt AI.

**Domanda a cui risponde:** *"Voglio fare ricerca semantica sui miei documenti e dare memoria ai miei modelli AI."*

---

## Cloud Personale

### Nextcloud

- **Container:** `nextcloud`
- **Porta:** `8080`
- **Immagine:** `nextcloud:latest`
- **Dati:** `./nextcloud/data`
- **Dipendenze:** MySQL, Redis

Piattaforma self-hosted per la gestione di file, calendario, contatti, note e collaborazione. Alternativa a Google Drive / Dropbox completamente sotto il proprio controllo. Utilizza MySQL come database e Redis come cache per le performance.

**Domanda a cui risponde:** *"Voglio un cloud personale per sincronizzare file, calendari e contatti senza affidarmi a servizi terzi."*

---

## Rete

Tutti i servizi comunicano attraverso una rete Docker interna (`internal`, driver bridge). Le porte sono esposte direttamente sull'host — al momento non c'e un reverse proxy con HTTPS (vedi `future.md` per l'evoluzione con Traefik).

---

## Variabili D'ambiente

- Le credenziali sono gestite tramite variabili d'ambiente nel file `.env`

-------------

# Future Improvements

## Infrastruttura / Networking

- **Traefik** — reverse proxy con HTTPS automatico (ora tutto è su porte esposte, niente TLS)
- **Portainer** — UI per gestire i container Docker
- **Tailscale** — VPN per accesso remoto sicuro

## Monitoring

- **Uptime Kuma** — monitoraggio uptime dei servizi
- **Grafana + Prometheus** — metriche e dashboard
- **Dozzle** — log viewer per container in tempo reale

## Sicurezza / Backup

- **Duplicati** o **Restic** — backup automatici
- **Vaultwarden** — password manager (Bitwarden self-hosted)
- **Authelia** o **Authentik** — SSO/2FA per proteggere i servizi

## Media / Utilità

- **Homepage** o **Homarr** — dashboard per tutti i servizi
- **Watchtower** — aggiornamento automatico immagini Docker

## AI (visto che hai Ollama + Qdrant)

- **Open WebUI** — interfaccia web per Ollama (come ChatGPT ma locale)

---

## Dettagli

### Portainer — Gestione container

- UI web per controllare Docker: start/stop/restart container, vedere volumi, reti, immagini
- Crei e modifichi container senza toccare la CLI
- Vedi log, exec dentro un container, gestisci stack compose
- È tipo un "Docker Desktop" remoto per il tuo server

### Monitoring (Uptime Kuma / Grafana+Prometheus / Dozzle) — Osservare lo stato

- **Uptime Kuma**: controlla se i servizi rispondono (ping, HTTP check). Ti manda notifiche se qualcosa va giù (Telegram, email, Discord)
- **Grafana + Prometheus**: raccoglie metriche (CPU, RAM, disco, richieste HTTP) e le mostra in dashboard grafiche nel tempo
- **Dozzle**: mostra i log in tempo reale di tutti i container in un'unica UI

### Dashboard (Homepage / Homarr) — Pagina di navigazione

- Una pagina web con link a tutti i tuoi servizi (Nextcloud, Ollama, ecc.)
- Mostra widget con info rapide (stato servizi, meteo, ecc.)
- È tipo una "home page personale" per il tuo homelab

### Watchtower — Aggiornamento automatico

- Controlla periodicamente se ci sono nuove versioni delle immagini Docker
- Le aggiorna automaticamente (pull + recreate)

---

## In sintesi

| Tool | Domanda a cui risponde |
|------|------------------------|
| Portainer | "Voglio gestire i container da browser" |
| Uptime Kuma | "È tutto online? Avvisami se qualcosa crasha" |
| Grafana+Prometheus | "Quanta RAM usa Postgres? C'è un trend?" |
| Dozzle | "Cosa stanno loggando i container adesso?" |
| Homepage/Homarr | "Dove trovo tutti i miei servizi?" |
| Watchtower | "Aggiorna tutto senza che ci pensi io" |

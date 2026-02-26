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

## Gestione Container

### Portainer

- **Container:** `portainer`
- **Porta:** `9000`
- **Immagine:** `portainer/portainer-ce:latest`
- **Dati:** `./portainer/data`

UI web per controllare Docker: start/stop/restart container, vedere volumi, reti, immagini. Permette di creare e modificare container senza toccare la CLI, visualizzare log, eseguire comandi dentro un container e gestire stack compose.

**Domanda a cui risponde:** *"Voglio gestire i container da browser, senza usare la CLI."*

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

## Media / Utilità

### Homepage

- **Container:** `homepage`
- **Porta:** `3002`
- **Immagine:** `ghcr.io/gethomepage/homepage:latest`
- **Config:** `./homepage/config`

Dashboard personale con link a tutti i servizi del server. Mostra widget con informazioni rapide (stato servizi, meteo, ecc.). Configurazione via file YAML, integrazione Docker per discovery automatico dei container.

**Domanda a cui risponde:** *"Dove trovo tutti i miei servizi in un'unica pagina?"*

---

### Watchtower

- **Container:** `watchtower`
- **Immagine:** `containrrr/watchtower:latest`

Controlla periodicamente se ci sono nuove versioni delle immagini Docker e le aggiorna automaticamente (pull + recreate). Configurato per pulire le vecchie immagini dopo l'aggiornamento. Intervallo di controllo configurabile via `WATCHTOWER_POLL_INTERVAL` (default: 86400s = 24h).

**Domanda a cui risponde:** *"Aggiorna tutto senza che ci pensi io."*

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

### Open WebUI

- **Container:** `open-webui`
- **Porta:** `8081`
- **Immagine:** `ghcr.io/open-webui/open-webui:main`
- **Dati:** `./open-webui/data`
- **Dipendenze:** Ollama

Interfaccia web per interagire con Ollama, simile a ChatGPT ma completamente locale. Supporta conversazioni multiple, gestione modelli, upload documenti e cronologia chat. Si connette automaticamente a Ollama sulla rete interna.

**Domanda a cui risponde:** *"Voglio chattare con i miei modelli AI da browser, come su ChatGPT."*

---

## Rete

Tutti i servizi comunicano attraverso una rete Docker interna (`internal`, driver bridge). Le porte sono esposte direttamente sull'host — al momento non c'è un reverse proxy con HTTPS (vedi Future Improvements per l'evoluzione con Traefik).

---

## Variabili D'ambiente

- Le credenziali sono gestite tramite variabili d'ambiente nel file `.env`

-------------

# Future Improvements

## Infrastruttura / Networking

- **Traefik** — reverse proxy con HTTPS automatico (ora tutto è su porte esposte, niente TLS)
- **Tailscale** — VPN per accesso remoto sicuro

## Sicurezza / Backup

- **Duplicati** o **Restic** — backup automatici
- **Vaultwarden** — password manager (Bitwarden self-hosted)

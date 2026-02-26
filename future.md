# Future Improvements

## Infrastruttura / Networking

- **Traefik** o **Nginx Proxy Manager** — reverse proxy con HTTPS automatico (ora tutto è su porte esposte, niente TLS)
- **Portainer** — UI per gestire i container Docker
- **WireGuard** / **Tailscale** — VPN per accesso remoto sicuro

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

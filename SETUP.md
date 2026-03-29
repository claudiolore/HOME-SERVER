# Setup Guide

Guida completa per installare e configurare il home server da zero.

## Indice

1. [Requisiti](#requisiti)
2. [Primo avvio](#primo-avvio)
3. [Configurazione AdGuard Home](#configurazione-adguard-home)
4. [Configurazione Tailscale DNS](#configurazione-tailscale-dns)
5. [Conflitto porta 53 su Linux](#conflitto-porta-53-su-linux)
6. [HTTPS per Vaultwarden](#https-per-vaultwarden)
7. [Servizi e URL](#servizi-e-url)
8. [Accesso fallback via IP:porta](#accesso-fallback-via-ipporta)

---

## Requisiti

- Docker e Docker Compose installati sul server
- Tailscale installato e attivo sul server
- Il server deve avere un IP Tailscale fisso (es. `100.123.95.105`)

---

## Primo avvio

**1. Clona il repository**

```bash
git clone <repo-url>
cd HOME-SERVER
```

**2. Crea il file `.env`**

```bash
cp .env.example .env
```

Modifica `.env` con i tuoi valori. Cambia **tutte** le voci `CHANGE_ME_*`:

```bash
nano .env
```

Imposta `SERVER_IP` con il tuo IP Tailscale:

```
SERVER_IP=100.x.x.x
```

**3. Avvia i container**

```bash
docker compose up -d
```

Verifica che tutti i container siano partiti:

```bash
docker compose ps
```

---

## Configurazione AdGuard Home

AdGuard Home funge da DNS server locale. Tutti i domini `*.home` vengono risolti verso il server, permettendo di accedere ai servizi con URL puliti come `nextcloud.home` invece di `IP:porta`.

### Setup iniziale (solo la prima volta)

**1.** Apri il wizard di configurazione nel browser:

```
http://<SERVER_IP>:3053
```

**2.** Segui il wizard:
- **Interfaccia admin:** lascia porta `3000`
- **DNS:** lascia `0.0.0.0:53`
- Crea username e password

**3.** Dopo il setup, accedi alla dashboard:

```
http://<SERVER_IP>:3053
```

### Aggiunta regola DNS wildcard

Questa regola fa sì che qualsiasi sottodominio `.home` punti al tuo server.

1. Vai su **Filtri** → **Riscritture DNS**
2. Clicca **Aggiungi riscrittura**
3. Inserisci:
   - **Dominio:** `*.home`
   - **IP:** il tuo `SERVER_IP` (es. `100.123.95.105`)
4. Salva

Da questo momento, `nextcloud.home`, `immich.home`, ecc. si risolvono tutti verso il server. Traefik smista le richieste al servizio corretto.

---

## Configurazione Tailscale DNS

Per far sì che tutti i device connessi via Tailscale usino AdGuard come DNS:

1. Vai su [admin.tailscale.com](https://admin.tailscale.com)
2. Clicca su **DNS**
3. In **Nameservers** → **Add nameserver** → **Custom**
4. Inserisci il tuo `SERVER_IP` (es. `100.123.95.105`)
5. Abilita **Override local DNS**

Da questo momento tutti i device Tailscale risolvono `*.home` verso il server senza nessuna configurazione aggiuntiva sui singoli device.

---

## Conflitto porta 53 su Linux

Su Ubuntu/Debian, `systemd-resolved` occupa di default la porta 53. Questo impedisce ad AdGuard di partire. Per risolvere:

```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

Poi assicurati che `/etc/resolv.conf` punti a un DNS valido (temporaneamente, prima che AdGuard sia attivo):

```bash
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
```

Dopo che AdGuard è attivo puoi aggiornarlo:

```bash
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
```

---

## HTTPS per Vaultwarden

Vaultwarden richiede HTTPS per funzionare con l'estensione browser e le app mobile.
La soluzione usata è un certificato Tailscale, valido e riconosciuto dai browser, senza aprire porte su internet.

### Come funziona

Tailscale rilascia certificati TLS validi per il dominio `<machine>.tail1234.ts.net` del tuo server.
Traefik usa questo certificato per esporre Vaultwarden su HTTPS a quell'indirizzo.

URL risultante: `https://<TAILSCALE_HOSTNAME>` (es. `https://homeserver.tail1234.ts.net`)

### Setup (solo la prima volta)

**1. Trova il tuo hostname Tailscale**

```bash
tailscale status --json | grep DNSName
```

Copia il valore (es. `homeserver.tail1234.ts.net`) — serve senza il punto finale.

**2. Aggiorna il file `.env`**

```
TAILSCALE_HOSTNAME=homeserver.tail1234.ts.net
```

**3. Abilita HTTPS su Tailscale**

Nel pannello [admin.tailscale.com](https://admin.tailscale.com):
- Vai su **DNS**
- Abilita **HTTPS Certificates**

**4. Genera il certificato sul server**

```bash
tailscale cert homeserver.tail1234.ts.net
```

Questo crea due file nella directory corrente:
- `homeserver.tail1234.ts.net.crt`
- `homeserver.tail1234.ts.net.key`

**5. Copia i certificati nella directory Traefik**

```bash
cp homeserver.tail1234.ts.net.crt ./traefik/certs/tailscale.crt
cp homeserver.tail1234.ts.net.key ./traefik/certs/tailscale.key
```

**6. Riavvia Traefik**

```bash
docker compose restart traefik
```

Vaultwarden è ora raggiungibile su `https://<TAILSCALE_HOSTNAME>` con certificato valido.

### Rinnovo del certificato

I certificati Tailscale scadono periodicamente. Per rinnovarli:

```bash
tailscale cert homeserver.tail1234.ts.net
cp homeserver.tail1234.ts.net.crt ./traefik/certs/tailscale.crt
cp homeserver.tail1234.ts.net.key ./traefik/certs/tailscale.key
docker compose restart traefik
```

---

## Servizi e URL

Una volta completato il setup, tutti i servizi sono raggiungibili dai device Tailscale tramite URL `.home`:

| Servizio | URL | Descrizione |
|---|---|---|
| Homepage | `http://start.home` | Dashboard con tutti i servizi |
| Nextcloud | `http://nextcloud.home` | Cloud personale e sync file |
| Immich | `http://immich.home` | Backup foto e video |
| Open WebUI | `http://webui.home` | Interfaccia AI (Ollama) |
| Vaultwarden | `https://<TAILSCALE_HOSTNAME>` | Password manager (HTTPS) |
| Portainer | `http://portainer.home` | Gestione container Docker |
| Grafana | `http://grafana.home` | Dashboard metriche |
| Prometheus | `http://prometheus.home` | Raccolta metriche |
| Uptime Kuma | `http://uptime.home` | Monitoraggio uptime servizi |
| Dozzle | `http://dozzle.home` | Log container in tempo reale |
| n8n | `http://n8n.home` | Automazione workflow |
| Vikunja | `http://vikunja.home` | Task e project management |
| AdGuard Home | `http://adguard.home` | DNS e blocco pubblicità |
| Traefik | `http://traefik.home` | Dashboard reverse proxy |

---

## Accesso fallback via IP:porta

Se AdGuard o Traefik non sono disponibili, tutti i servizi web rimangono accessibili direttamente tramite IP e porta:

| Servizio | URL diretto |
|---|---|
| Nextcloud | `http://<SERVER_IP>:8080` |
| Immich | `http://<SERVER_IP>:2283` |
| Open WebUI | `http://<SERVER_IP>:8081` |
| Vaultwarden | `http://<SERVER_IP>:8222` |
| Portainer | `http://<SERVER_IP>:9000` |
| Homepage | `http://<SERVER_IP>:3002` |
| Grafana | `http://<SERVER_IP>:3000` |
| Uptime Kuma | `http://<SERVER_IP>:3001` |
| Dozzle | `http://<SERVER_IP>:8888` |
| n8n | `http://<SERVER_IP>:5678` |
| Vikunja | `http://<SERVER_IP>:3456` |
| Prometheus | `http://<SERVER_IP>:9090` |
| Traefik dashboard | `http://<SERVER_IP>:8082` |
| AdGuard setup | `http://<SERVER_IP>:3053` |

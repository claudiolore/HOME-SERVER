# Guida: Tailscale + Dominio Proprio per il Home Server

Questa guida configura l'accesso ai servizi tramite sottodomini puliti
(es. `grafana.TUODOMINIO.COM`) usando il tuo dominio esistente e Tailscale
come VPN privata.

**Risultato finale:**

| Servizio     | URL                                  |
|--------------|--------------------------------------|
| Homepage     | `http://TUODOMINIO.COM`              |
| Nextcloud    | `http://nextcloud.TUODOMINIO.COM`    |
| Grafana      | `http://grafana.TUODOMINIO.COM`      |
| Portainer    | `http://portainer.TUODOMINIO.COM`    |
| Vaultwarden  | `http://vaultwarden.TUODOMINIO.COM`  |
| Open WebUI   | `http://ai.TUODOMINIO.COM`           |
| Traefik      | `http://traefik.TUODOMINIO.COM/dashboard/` |
| ...          | ...                                  |

> Sostituisci `TUODOMINIO.COM` con il tuo dominio reale in tutta la guida.

---

## Come funziona (concetto chiave)

```
Il tuo PC (connesso a Tailscale)
    │
    │  digita: grafana.TUODOMINIO.COM
    ▼
DNS pubblico risolve → 100.114.47.75   ← IP Tailscale del server
    │
    │  (solo i device nella tua tailnet raggiungono questo IP)
    ▼
Traefik sul server
    │
    │  legge l'header Host: grafana.TUODOMINIO.COM
    ▼
Grafana :3000
```

**Perché è sicuro:** l'IP `100.x.x.x` è un indirizzo Tailscale privato.
Anche se il record DNS è pubblico e chiunque può risolverlo, nessuno
può raggiungerlo senza essere connesso alla tua tailnet.
I servizi restano **privati per design**.

---

## Passo 1 — Installare Tailscale sul server

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

All'esecuzione di `tailscale up` viene mostrato un link: aprilo nel browser
e autenticati con il tuo account Tailscale.

Verifica che il server sia online e annota il suo IP Tailscale:

```bash
tailscale status
# Esempio output:
# 100.114.47.75   myhomeserver   user@email.com  linux   -
```

---

## Passo 2 — Installare Tailscale sui client

Installa l'app su ogni dispositivo che userai per accedere ai servizi.
Accedi sempre con lo **stesso account** Tailscale.

| Dispositivo | Download |
|-------------|----------|
| Windows     | https://tailscale.com/download/windows |
| macOS       | https://tailscale.com/download/mac |
| Linux       | `curl -fsSL https://tailscale.com/install.sh \| sh` |
| iPhone/iPad | App Store → "Tailscale" |
| Android     | Play Store → "Tailscale" |

---

## Passo 3 — Aggiungere il record DNS wildcard

Accedi al pannello DNS del tuo registrar (Cloudflare, Namecheap, ecc.)
e aggiungi **un solo record**:

| Campo  | Valore                        |
|--------|-------------------------------|
| Tipo   | `A`                           |
| Nome   | `*` (wildcard)                |
| Valore | `100.114.47.75` ← il tuo IP Tailscale |
| TTL    | Auto / 300                    |
| Proxy  | **Disabilitato** (DNS only, niente arancione Cloudflare) |

> **Perché disabilitare il proxy Cloudflare?**
> Il proxy di Cloudflare instraderebbe il traffico attraverso i server
> Cloudflare, ma l'IP di destinazione è privato (Tailscale) e non
> raggiungibile da internet. Con il proxy disabilitato, il DNS restituisce
> direttamente l'IP Tailscale al client, che ci si connette direttamente.

Il record `*` copre **tutti** i sottodomini con un'unica voce:
`grafana.TUODOMINIO.COM`, `nextcloud.TUODOMINIO.COM`, ecc.

Aggiungi anche un record per il dominio root se vuoi che `TUODOMINIO.COM`
(senza sottodominio) punti a Homepage:

| Campo  | Valore          |
|--------|-----------------|
| Tipo   | `A`             |
| Nome   | `@`             |
| Valore | `100.114.47.75` |

---

## Passo 4 — Configurare il `.env`

```bash
cp .env.example .env
```

Apri `.env` e imposta:

```env
DOMAIN=TUODOMINIO.COM
```

Compila anche tutte le altre variabili con le tue password reali.

---

## Passo 5 — Avviare i servizi

```bash
# Crea le directory e i permessi necessari
bash init.sh

# Avvia tutti i container
docker compose up -d

# Controlla che Traefik sia partito senza errori
docker logs traefik --tail 30
```

---

## Passo 6 — Verificare

Connettiti a Tailscale dal tuo PC e apri nel browser:

```
http://traefik.TUODOMINIO.COM/dashboard/
```

Se vedi il dashboard Traefik, il routing funziona.
Dovresti vedere nella sezione **HTTP Routers** tutti i servizi configurati.

Poi prova gli altri servizi uno alla volta:

```
http://TUODOMINIO.COM              → Homepage
http://grafana.TUODOMINIO.COM      → Grafana
http://portainer.TUODOMINIO.COM    → Portainer
http://nextcloud.TUODOMINIO.COM    → Nextcloud
```

---

## Troubleshooting

**Il browser non trova il dominio:**
```bash
# Verifica che Tailscale sia connesso sul client
tailscale status

# Verifica che il DNS risolva correttamente
nslookup grafana.TUODOMINIO.COM
# Deve rispondere con 100.x.x.x (IP Tailscale)

# Prova a pingare il server
ping 100.114.47.75
```

**Il DNS risolve ma la pagina non si apre:**
```bash
# Verifica che Traefik sia in ascolto
docker ps | grep traefik

# Controlla i log di Traefik
docker logs traefik --tail 50
```

**Traefik risponde ma il servizio sbagliato (o 404):**
Apri `http://traefik.TUODOMINIO.COM/dashboard/` → sezione **HTTP Routers**
e verifica che la rule del servizio sia corretta.

**Nextcloud dà errore "untrusted domain":**
Nel `.env` verifica che sia presente:
```env
NEXTCLOUD_TRUSTED_DOMAINS=nextcloud.TUODOMINIO.COM
```
Poi:
```bash
docker compose restart nextcloud
```

---

## Aggiungere HTTPS con Let's Encrypt (opzionale)

Una volta che tutto funziona in HTTP, aggiungere HTTPS è semplice.
Richiede che il tuo dominio sia raggiungibile pubblicamente sulla porta 443
(o che usi la DNS challenge di Cloudflare).

Sarà trattato in una guida separata.

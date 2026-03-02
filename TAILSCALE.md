# Guida: Tailscale + MagicDNS per il Home Server

Questa guida spiega come configurare Tailscale sul server e sui tuoi dispositivi
in modo che tutti i servizi siano raggiungibili via sottodominio (es. `grafana.nomemacchina.ts.net`)
senza toccare DNS manuali o file `/etc/hosts`.

---

## 1. Cos'è Tailscale

Tailscale è una VPN mesh basata su WireGuard. Crea una rete privata virtuale
tra tutti i tuoi dispositivi (server, PC, telefono, ecc.) usando indirizzi IP
stabili nel range `100.x.x.x`, indipendentemente da dove si trovano fisicamente.

**MagicDNS** è la funzione che assegna automaticamente un nome DNS a ogni
macchina nella tua tailnet, risolvendo il problema del DNS senza configurazione manuale.

---

## 2. Installare Tailscale sul server

```bash
# Installa Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Avvia e autenticati (si apre un link nel browser)
sudo tailscale up

# Verifica che il server sia online
tailscale status
```

L'output di `tailscale status` mostrerà qualcosa come:

```
100.114.47.75   myhomeserver   user@email.com  linux   -
```

Annota il **nome macchina** (es. `myhomeserver`) — ti servirà dopo.

---

## 3. Installare Tailscale sui client

Installa l'app Tailscale su ogni dispositivo da cui vuoi accedere al server:

| Dispositivo | Link |
|-------------|------|
| Windows     | https://tailscale.com/download/windows |
| macOS       | https://tailscale.com/download/mac |
| Linux       | `curl -fsSL https://tailscale.com/install.sh \| sh` |
| iPhone/iPad | App Store → "Tailscale" |
| Android     | Play Store → "Tailscale" |

Accedi con lo **stesso account** usato sul server.

---

## 4. Abilitare MagicDNS

1. Vai su [https://login.tailscale.com/admin/dns](https://login.tailscale.com/admin/dns)
2. Nella sezione **MagicDNS**, clicca **Enable MagicDNS**
3. Nella sezione **Nameservers**, aggiungi un nameserver globale (es. `1.1.1.1` di Cloudflare)
   — serve per risolvere i domini internet normali mentre sei connesso in Tailscale

Dopo l'attivazione, ogni macchina nella tua tailnet è raggiungibile con:
```
nomemacchina.nome-tailnet.ts.net
```

Puoi trovare il nome completo della tua tailnet nel pannello admin → **DNS** → **Tailnet name**.

---

## 5. Trovare il tuo dominio Tailscale

Sul server, esegui:

```bash
tailscale status --json | python3 -c "
import json, sys
d = json.load(sys.stdin)
me = d['Self']
print('IP Tailscale: ', me['TailscaleIPs'][0])
print('Nome DNS:     ', me['DNSName'].rstrip('.'))
"
```

Output di esempio:
```
IP Tailscale:  100.114.47.75
Nome DNS:      myhomeserver.tail1234abc.ts.net
```

---

## 6. Configurare il `.env` del Home Server

Copia `.env.example` in `.env` e imposta `DOMAIN` con il nome DNS della tua macchina:

```bash
cp .env.example .env
```

Modifica `.env`:

```env
# Metti qui il nome DNS completo del tuo server Tailscale
DOMAIN=myhomeserver.tail1234abc.ts.net
```

> **Importante:** non usare il prefisso `http://` — solo il nome dominio.

---

## 7. Configurare i sottodomini wildcard (opzionale ma consigliato)

Per default, MagicDNS risolve solo `myhomeserver.tail1234abc.ts.net`.
I sottodomini come `grafana.myhomeserver.tail1234abc.ts.net` **non** vengono
risolti automaticamente da Tailscale.

### Soluzione A — Split DNS con nameserver locale (Pi-hole / AdGuard Home)

Se hai Pi-hole o AdGuard Home nella tua rete:

1. Aggiungi un record DNS wildcard nel tuo resolver locale:
   ```
   *.myhomeserver.tail1234abc.ts.net → 100.114.47.75
   ```
2. Nel pannello Tailscale → **DNS** → **Nameservers**, aggiungi il tuo resolver
   come nameserver per il dominio `.ts.net` (Split DNS).

### Soluzione B — `/etc/hosts` su ogni client (più semplice)

Su ogni dispositivo client aggiungi queste righe al file hosts:

**Linux / macOS:** `/etc/hosts`
**Windows:** `C:\Windows\System32\drivers\etc\hosts`

```
100.114.47.75  myhomeserver.tail1234abc.ts.net
100.114.47.75  nextcloud.myhomeserver.tail1234abc.ts.net
100.114.47.75  vaultwarden.myhomeserver.tail1234abc.ts.net
100.114.47.75  portainer.myhomeserver.tail1234abc.ts.net
100.114.47.75  grafana.myhomeserver.tail1234abc.ts.net
100.114.47.75  prometheus.myhomeserver.tail1234abc.ts.net
100.114.47.75  uptime.myhomeserver.tail1234abc.ts.net
100.114.47.75  dozzle.myhomeserver.tail1234abc.ts.net
100.114.47.75  ai.myhomeserver.tail1234abc.ts.net
100.114.47.75  traefik.myhomeserver.tail1234abc.ts.net
```

### Soluzione C — Usare un dominio pubblico (se ce l'hai)

Se possiedi un dominio (es. `esempio.com`), puoi:
1. Aggiungere un record A wildcard: `*.homeserver.esempio.com → 100.114.47.75`
2. Impostare `DOMAIN=homeserver.esempio.com` nel `.env`

Questo funziona da qualsiasi rete, anche fuori Tailscale, purché il server
sia raggiungibile (o punti all'IP Tailscale e tutti i client usino Tailscale).

---

## 8. Avviare i servizi

```bash
# Prima avvio
bash init.sh
docker compose up -d

# Verifica che Traefik sia attivo
docker logs traefik --tail 20
```

---

## 9. Verificare il routing

Apri il browser su un dispositivo connesso a Tailscale e prova:

| URL | Risultato atteso |
|-----|-----------------|
| `http://myhomeserver.tail1234abc.ts.net` | Homepage dashboard |
| `http://traefik.myhomeserver.tail1234abc.ts.net/dashboard/` | Traefik dashboard |
| `http://grafana.myhomeserver.tail1234abc.ts.net` | Grafana |
| `http://portainer.myhomeserver.tail1234abc.ts.net` | Portainer |

Se il dashboard Traefik è raggiungibile, il routing funziona correttamente.

---

## 10. Troubleshooting

**Il browser non trova il dominio:**
```bash
# Verifica che Tailscale sia connesso sul client
tailscale status

# Prova a pingare il server dal client
ping 100.114.47.75

# Verifica che Traefik sia in ascolto sulla porta 80
docker ps | grep traefik
```

**Traefik non routa al servizio giusto:**
```bash
# Controlla i logs di Traefik
docker logs traefik --tail 50

# Verifica che i labels siano stati letti correttamente
# apri http://traefik.DOMAIN/dashboard/ → sezione "HTTP Routers"
```

**Nextcloud dà errore "untrusted domain":**
Assicurati che `NEXTCLOUD_TRUSTED_DOMAINS` nel `.env` contenga il dominio esatto
con cui stai accedendo:
```env
NEXTCLOUD_TRUSTED_DOMAINS=nextcloud.myhomeserver.tail1234abc.ts.net
```
Poi riavvia: `docker compose restart nextcloud`

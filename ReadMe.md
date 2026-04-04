# Homelab

Stack Docker auto-hébergée composée de ~25 services organisés par catégorie.

![First Page of Glance Dashboard](https://private-user-images.githubusercontent.com/118174685/540161522-d2472341-ec71-43ea-aeb8-e315d62b6719.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NzUxOTc3MzIsIm5iZiI6MTc3NTE5NzQzMiwicGF0aCI6Ii8xMTgxNzQ2ODUvNTQwMTYxNTIyLWQyNDcyMzQxLWVjNzEtNDNlYS1hZWI4LWUzMTVkNjJiNjcxOS5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjYwNDAzJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI2MDQwM1QwNjIzNTJaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT01ODcxYzAzMTJjOTcyNTAzNDc0ZjU2ZjNhMGRiOGZjNjE1NGY0YzBmZTcyZGIzMzc3MWIxMDIwZjgyM2YzMDI0JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.cr_XULPPE9_6twKAqjfBEE5m3QoX0yduXWBCdctlwjw)

![Second Page of Glance Dashboard](https://private-user-images.githubusercontent.com/118174685/540161572-8b989ea8-caf7-44bd-bac6-e02c6a39cd0d.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NzUxOTc3MzIsIm5iZiI6MTc3NTE5NzQzMiwicGF0aCI6Ii8xMTgxNzQ2ODUvNTQwMTYxNTcyLThiOTg5ZWE4LWNhZjctNDRiZC1iYWM2LWUwMmM2YTM5Y2QwZC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjYwNDAzJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI2MDQwM1QwNjIzNTJaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1lYzAzMTYzNjAzYWVhOWQ4ZjMwOTMyMjVlYzFkZmUyMzc2Mjg4ZjRhOTcxOWMxZjQ2ZGYwNGVmY2QzOGVkOTBiJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.Juv1uvVByhATeD4KHSJEbAqu8a7W6iQtih7hYRhHLnA)

![Architecture](https://private-user-images.githubusercontent.com/118174685/573823813-3a01cf4f-4f33-47bf-b9fd-4cf8de131a2e.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NzUzMDg3MTcsIm5iZiI6MTc3NTMwODQxNywicGF0aCI6Ii8xMTgxNzQ2ODUvNTczODIzODEzLTNhMDFjZjRmLTRmMzMtNDdiZi1iOWZkLTRjZjhkZTEzMWEyZS5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjYwNDA0JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI2MDQwNFQxMzEzMzdaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1mZWIxMGMzNmU0NGM2YjgwOGMxOWY1N2ExZGEzNjNmNzlkODljMmIzMTI5MTViODJiNmZjNzY1ZGY4NGJlNWQxJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.M-xGAEMSxNMR44zAof3oJkqbhrzEVXoIHebEUJFqU_M)

## Prérequis

- Docker (version récente — Docker Compose v2 inclus)
- Git
- Un VPN WireGuard actif (requis pour qBittorrent via Gluetun)
- Un nom de domaine *(optionnel — requis pour le mode web)*

## Installation

```bash
git clone <repo-url> ~/homelab
cd ~/homelab
make setup
```

Le wizard guide toutes les étapes : env, dossiers, proxy hosts NPM, Glance.

---

## Accès aux services

NPM reçoit toutes les requêtes HTTP/HTTPS et les route vers le bon service selon le nom de domaine. Il faut donc que les noms de domaine pointent vers l'IP de la machine qui tourne NPM. Deux approches :

### Option A — Local (`/etc/hosts`)

Le wizard génère et écrit automatiquement les entrées dans `/etc/hosts` en mode local. Les services sont accessibles uniquement depuis la machine où le fichier a été modifié.

### Option B — Tailscale + AdGuard Home (recommandé)

Cette configuration permet d'accéder à tous les services depuis n'importe quel appareil connecté au tailnet, sans exposer quoi que ce soit sur internet.

**Flux :**
```
Appareil (sur le tailnet)
  → DNS: jellyfin.mondomaine.com ?
  → Tailscale Split DNS → AdGuard Home (100.x.x.x:53)
  → Rewrite DNS: *.mondomaine.com → IP Tailscale de la machine NPM
  → Requête HTTPS vers NPM
  → NPM route vers le conteneur jellyfin
```

**Étapes :**

1. **Trouver l'IP Tailscale de la machine** qui fait tourner la stack :
   ```bash
   tailscale ip -4
   # ex: 100.75.142.70
   ```

2. **Configurer AdGuard Home** — dans l'interface AdGuard, va dans **Filtres → Réécriture DNS** et ajoute une règle wildcard :
   - Domaine : `*.mondomaine.com`
   - Réponse : `100.75.142.70` *(IP Tailscale de la machine NPM)*

   > AdGuard ne fait que du DNS — il ne proxifie pas le trafic HTTP. Il répond uniquement à la question "quelle IP pour ce domaine ?", c'est NPM qui fait le routage.

3. **Configurer Tailscale Split DNS** — dans la [console Tailscale](https://login.tailscale.com/admin/dns) :
   - Section **Nameservers** → **Add nameserver** → **Custom**
   - IP : `100.75.142.70` *(IP Tailscale de la machine AdGuard)*
   - Cocher **Restrict to domain** et entrer `mondomaine.com`

   Tous les appareils du tailnet résoudront `*.mondomaine.com` via AdGuard automatiquement.

---

## Configuration post-démarrage

### Certificats SSL (Nginx Proxy Manager)

Les certificats Let's Encrypt sont à créer manuellement dans l'interface NPM après le premier démarrage.

### qBittorrent

qBittorrent nécessite un patch après son premier démarrage. Arrête le conteneur, ajoute dans `${VOLUME_ROOT}/qbittorrent/qBittorrent/config/qBittorrent.conf` :

```ini
WebUI\CSRFProtection=false
WebUI\HostHeaderValidation=false
WebUI\LocalHostAuthentication=false
```

Dans l'interface web → **Paramètres → Avancé** :
- Interface réseau : `tun0` / type d'adresses : `IPv4`
- Dossier de téléchargement par défaut

---

## Pipeline media

### Vue d'ensemble

```
Internet → Prowlarr (indexeurs)
              ↓
        FlareSolverr (anti-Cloudflare)
              ↓
    Sonarr ──────── Radarr
       │                │
       └──── Bazarr ────┘   (sous-titres)
       │                │
       └── qBittorrent ─┘   (téléchargements via gluetun)
       │                │
       └─── Jellyfin ───┘   (notifications + scan)
              ↑
          Jellyseerr         (requêtes utilisateurs)
```

Tous ces services partagent `homelab-network` — utilise toujours les **URLs internes** ci-dessous (pas `localhost`, pas l'IP de la machine).

| Service       | URL interne                   | Où trouver l'API Key |
|---------------|-------------------------------|----------------------|
| Sonarr        | `http://sonarr:8989`          | Paramètres → Général → API Key |
| Radarr        | `http://radarr:7878`          | Paramètres → Général → API Key |
| Prowlarr      | `http://prowlarr:9696`        | Paramètres → Général → API Key |
| qBittorrent   | `http://gluetun:8080`         | WebUI → Paramètres → Web UI |
| Jellyfin      | `http://jellyfin:8096`        | Tableau de bord → Clés API |
| FlareSolverr  | `http://flaresolverr:8191`    | — (pas d'auth) |
| Bazarr        | `http://bazarr:6767`          | Paramètres → Général → API Key |

---

### Étape 1 — Prowlarr → FlareSolverr

FlareSolverr permet d'accéder aux indexeurs protégés par Cloudflare.

Dans **Prowlarr** → Paramètres → Indexeurs → Proxies → `+` :
- Type : `FlareSolverr`
- URL : `http://flaresolverr:8191`
- Tag : `flaresolverr` *(assigne ce tag aux indexeurs qui en ont besoin)*

---

### Étape 2 — Prowlarr → Sonarr & Radarr

Prowlarr pousse sa liste d'indexeurs vers Sonarr/Radarr automatiquement via leur API.

Dans **Prowlarr** → Paramètres → Apps → `+` :

**Pour Sonarr :**
- Application : `Sonarr`
- URL Prowlarr : `http://prowlarr:9696`
- URL Sonarr : `http://sonarr:8989`
- API Key : *(clé API de Sonarr)*
- Sync Level : `Full Sync`

**Pour Radarr :**
- Application : `Radarr`
- URL Prowlarr : `http://prowlarr:9696`
- URL Radarr : `http://radarr:7878`
- API Key : *(clé API de Radarr)*
- Sync Level : `Full Sync`

Clique sur **Test** puis **Save**. Les indexeurs apparaissent automatiquement dans Sonarr/Radarr.

---

### Étape 3 — Sonarr & Radarr → qBittorrent

> qBittorrent partage le réseau du container Gluetun → adresse `gluetun:8080`.

Dans **Sonarr** → Paramètres → Clients de téléchargement → `+` → qBittorrent :
- Hôte : `gluetun`
- Port : `8080`
- Nom d'utilisateur / Mot de passe : *(WebUI qBittorrent)*
- Catégorie : `tv-sonarr`

Dans **Radarr** → Paramètres → Clients de téléchargement → `+` → qBittorrent :
- Hôte : `gluetun`
- Port : `8080`
- Nom d'utilisateur / Mot de passe : *(WebUI qBittorrent)*
- Catégorie : `radarr`

> Dans qBittorrent → Paramètres → Avancé : Interface réseau = `tun0`, Adresses = `IPv4`.

---

### Étape 4 — Sonarr & Radarr → Jellyfin

Sonarr/Radarr notifient Jellyfin pour déclencher un scan après chaque téléchargement.

Dans **Sonarr** → Paramètres → Connexions → `+` → Emby/Jellyfin :
- URL : `http://jellyfin:8096`
- API Key : *(clé API Jellyfin)*
- Cocher : `Mise à jour de la bibliothèque après importation`

Même manipulation dans **Radarr**.

---

### Étape 5 — Jellyseerr → Jellyfin + Sonarr + Radarr

Au premier accès à Jellyseerr, un assistant de configuration se lance.

1. **Connexion Jellyfin** :
   - URL : `http://jellyfin:8096`
   - API Key : *(clé API Jellyfin)*
   - Sélectionne les bibliothèques à exposer dans Jellyseerr

2. **Ajout Radarr** (Paramètres → Services → Radarr → `+`) :
   - URL : `http://radarr:7878`
   - API Key : *(clé API Radarr)*
   - Cocher `Default Server`
   - Sélectionne le profil de qualité et le dossier racine `/data/media/movies`

3. **Ajout Sonarr** (Paramètres → Services → Sonarr → `+`) :
   - URL : `http://sonarr:8989`
   - API Key : *(clé API Sonarr)*
   - Cocher `Default Server`
   - Sélectionne le profil de qualité et le dossier racine `/data/media/tv`

---

### Étape 6 — Bazarr → Sonarr & Radarr

Bazarr synchronise les sous-titres avec les bibliothèques Sonarr/Radarr.

Dans **Bazarr** → Paramètres → Sonarr :
- URL : `http://sonarr:8989`
- API Key : *(clé API Sonarr)*
- Cocher `Enabled`

Dans **Bazarr** → Paramètres → Radarr :
- URL : `http://radarr:7878`
- API Key : *(clé API Radarr)*
- Cocher `Enabled`

Puis Paramètres → Sous-titres : configure les langues souhaitées (ex: `fr`, `en`) et les providers (OpenSubtitles, Subscene…).

> **Note** : Bazarr accède aux fichiers via `/movies` (films) et `/tv` (séries). Ces chemins correspondent à `${MEDIA_ROOT}/movies` et `${MEDIA_ROOT}/tv` sur l'hôte.
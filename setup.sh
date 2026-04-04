#!/usr/bin/env bash
# =============================================================================
# Homelab Setup Wizard
# Compatible : macOS (BSD sed) + Linux (GNU sed)
# Usage : bash setup.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Variables partagées entre les étapes du wizard
_NET_MODE=""      # "web" ou "local"
_DOMAIN=""        # domaine choisi par l'utilisateur
_ADGUARD_IP=""    # IP d'AdGuard Home (hors réseau Docker)
_HOSTS_ENTRIES=() # Entrées /etc/hosts à ajouter (mode local)

# ─────────────────────────────────────────────────────────────────────────────
# Couleurs & helpers
# ─────────────────────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  GREEN='\033[0;32m'; YELLOW='\033[1;33m'
  BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'
else
  GREEN=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; DIM=''; RESET=''
fi

info()    { echo -e "${CYAN}▸${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $*"; }
error()   { echo -e "\033[0;31m✗\033[0m $*" >&2; }
header()  { echo -e "\n${BOLD}${BLUE}━━━ $* ━━━${RESET}\n"; }
divider() { echo -e "${DIM}────────────────────────────────────────${RESET}"; }

ask() {
  local prompt="$1" default="${2:-}" var
  if [ -n "$default" ]; then
    read -rp "$(echo -e "  ${CYAN}?${RESET} $prompt ${DIM}[$default]${RESET} : ")" var
    echo "${var:-$default}"
  else
    read -rp "$(echo -e "  ${CYAN}?${RESET} $prompt : ")" var
    echo "$var"
  fi
}

ask_secret() {
  local prompt="$1" var
  read -rsp "$(echo -e "  ${CYAN}?${RESET} $prompt : ")" var
  echo >&2
  echo "$var"
}

# Retourne 0 si oui, 1 si non
confirm() {
  local prompt="$1" default="${2:-y}" yn
  local hint; [ "$default" = "y" ] && hint="O/n" || hint="o/N"
  read -rp "$(echo -e "  ${CYAN}?${RESET} $prompt ${DIM}[$hint]${RESET} : ")" yn
  yn="${yn:-$default}"
  [[ "$yn" =~ ^[OoYy]$ ]]
}

press_enter() {
  echo
  read -rp "$(echo -e "  ${DIM}Entrée pour continuer...${RESET}")" _
}

_sed_inplace() {
  # BSD (macOS) : sed -i ''   /   GNU (Linux) : sed -i
  if sed --version 2>/dev/null | grep -q GNU; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

load_env() {
  [ -f "$SCRIPT_DIR/.env" ] || return 0
  set -a
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
  set +a
}

# ─────────────────────────────────────────────────────────────────────────────
# Étape 1 — Dépendances
# ─────────────────────────────────────────────────────────────────────────────
step_check_deps() {
  header "1 / 5 — Vérification des dépendances"

  local ok=true
  for cmd in docker git; do
    if command -v "$cmd" &>/dev/null; then
      success "$cmd — $("$cmd" --version 2>&1 | head -1)"
    else
      error "$cmd non trouvé"
      ok=false
    fi
  done

  if docker compose version &>/dev/null 2>&1; then
    success "docker compose v2 disponible"
  else
    error "docker compose v2 introuvable (installe le plugin Docker Compose)"
    ok=false
  fi

  $ok || { error "Dépendances manquantes — installe-les et relance le wizard."; exit 1; }
}

# ─────────────────────────────────────────────────────────────────────────────
# Étape 2 — Fichiers .env
# ─────────────────────────────────────────────────────────────────────────────
ENV_PAIRS=(
  ".env.example:.env"
  "dc/code-server/.env.example:dc/code-server/.env"
  "dc/duplicati/.env.example:dc/duplicati/.env"
  "dc/gluetun/.env.example:dc/gluetun/.env"
  "dc/immich/.env.example:dc/immich/.env"
)

step_env() {
  header "2 / 5 — Configuration des fichiers .env"

  # Copie des .env.example manquants
  for pair in "${ENV_PAIRS[@]}"; do
    local src="${SCRIPT_DIR}/${pair%%:*}"
    local dst="${SCRIPT_DIR}/${pair##*:}"
    [ ! -f "$src" ] && continue
    if [ -f "$dst" ]; then
      warn "$(basename "$dst") existe déjà — ignoré"
    else
      cp "$src" "$dst"
      success "Créé : ${pair##*:}"
    fi
  done

  echo
  divider
  info ".env principal"
  divider
  echo

  local puid pgid tz vol_root data_root media_root ssd

  puid=$(ask "PUID" "1000")
  pgid=$(ask "PGID" "1000")
  tz=$(ask "Timezone" "Europe/Paris")
  vol_root=$(ask "VOLUME_ROOT — données Docker" "$HOME/docker-data")
  data_root=$(ask "DATA_ROOT" "$HOME/data")
  media_root=$(ask "MEDIA_ROOT" "$HOME/data/media")
  ssd=$(ask "STORAGE_ROOT — SSD externe (laisser vide si inutilisé)" "/mnt/storage")

  _sed_inplace \
    -e "s|^PUID=.*|PUID=$puid|" \
    -e "s|^PGID=.*|PGID=$pgid|" \
    -e "s|^TZ=.*|TZ=$tz|" \
    -e "s|^VOLUME_ROOT=.*|VOLUME_ROOT=$vol_root|" \
    -e "s|^DATA_ROOT=.*|DATA_ROOT=$data_root|" \
    -e "s|^MEDIA_ROOT=.*|MEDIA_ROOT=$media_root|" \
    -e "s|^STORAGE_ROOT=.*|STORAGE_ROOT=$ssd|" \
    "$SCRIPT_DIR/.env"
  success ".env principal configuré"

  # Code Server
  if [ -f "$SCRIPT_DIR/dc/code-server/.env" ]; then
    echo; divider; info "Code Server"; divider; echo
    local cs_pass
    cs_pass=$(ask_secret "Mot de passe")
    _sed_inplace "s|^CODE_SERVER_PASSWORD=.*|CODE_SERVER_PASSWORD=$cs_pass|" \
      "$SCRIPT_DIR/dc/code-server/.env"
    success "code-server .env configuré"
  fi

  # Immich
  if [ -f "$SCRIPT_DIR/dc/immich/.env" ]; then
    echo; divider; info "Immich"; divider; echo
    local upload_loc db_pass
    upload_loc=$(ask "UPLOAD_LOCATION (dossier photos)" "$ssd/data/photos")
    db_pass=$(ask_secret "DB_PASSWORD")
    _sed_inplace \
      -e "s|^UPLOAD_LOCATION=.*|UPLOAD_LOCATION=$upload_loc|" \
      -e "s|^DB_PASSWORD=.*|DB_PASSWORD=$db_pass|" \
      "$SCRIPT_DIR/dc/immich/.env"
    success "immich .env configuré"
  fi


  # Gluetun
  if [ -f "$SCRIPT_DIR/dc/gluetun/.env" ]; then
    echo; divider; info "Gluetun (VPN WireGuard)"; divider; echo
    local wg_key wg_addr wg_psk
    wg_key=$(ask_secret "WireGuard Private Key")
    wg_addr=$(ask "WireGuard Address (ex: 10.x.x.x/32)" "")
    wg_psk=$(ask_secret "WireGuard Preshared Key (Entrée pour ignorer)")
    _sed_inplace \
      -e "s|^VPN_WIREGUARD_PRIVATE_KEY=.*|VPN_WIREGUARD_PRIVATE_KEY=$wg_key|" \
      -e "s|^VPN_WIREGUARD_ADDRESSES=.*|VPN_WIREGUARD_ADDRESSES=$wg_addr|" \
      -e "s|^VPN_WIREGUARD_PRESHARED_KEY=.*|VPN_WIREGUARD_PRESHARED_KEY=$wg_psk|" \
      "$SCRIPT_DIR/dc/gluetun/.env"
    success "gluetun .env configuré"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Étape 3 — Dossiers
# ─────────────────────────────────────────────────────────────────────────────
step_dirs() {
  header "3 / 5 — Création des dossiers"
  load_env

  local vol="${VOLUME_ROOT:-$HOME/docker-data}"
  local data="${DATA_ROOT:-$HOME/data}"
  local media="${MEDIA_ROOT:-$HOME/data/media}"
  local ssd="${STORAGE_ROOT:-}"

  local dirs=(
    "$vol"
    "$data"
    "$media/movies"
    "$media/tv"
    "$media/music"
    "$media/books"
    "$vol/npm/data/nginx/proxy_host"
    "$vol/glance/config"
    "$vol/adguardhome/work"
    "$vol/adguardhome/conf"
  )

  for d in "${dirs[@]}"; do
    mkdir -p "$d" && success "$d"
  done

  if [ -n "$ssd" ]; then
    if mkdir -p "$ssd" 2>/dev/null; then
      success "$ssd"
    else
      warn "Stockage non accessible : $ssd — monte-le avant de démarrer les services."
    fi
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Étape 4 — Proxy hosts NPM
# ─────────────────────────────────────────────────────────────────────────────

# Registre : "Nom|conteneur_ou_IP|port|sous-domaine|websocket|type(docker/ip)"
# websocket=yes → ajoute les headers Upgrade/Connection
# type=ip       → demande une adresse IP (service hors réseau Docker)
SERVICES=(
  "AdGuard Home|PLACEHOLDER|8080|adguard|no|ip"
  "Bazarr|bazarr|6767|bazarr|no|docker"
  "Calibre Web|calibre-web|8083|calibre|no|docker"
  "Code Server|code-server|8443|code|yes|docker"
  "Duplicati|duplicati|8200|duplicati|yes|docker"
  "File Browser|filebrowser|80|filebrowser|no|docker"
  "Glance|glance|8080|glance|no|docker"
  "Jellyfin|jellyfin|8096|jellyfin|no|docker"
  "Jellyseerr|jellyseerr|5055|jellyseerr|no|docker"
  "Mealie|mealie|9000|mealie|no|docker"
  "Netdata|netdata|19999|netdata|yes|docker"
  "Nginx Proxy Manager|nginx-proxy-manager|81|nginx|no|docker"
  "Immich|immich-server|2283|photos|no|docker"
  "Podgrab|podgrab|8080|podgrab|no|docker"
  "Portainer|portainer|9000|portainer|yes|docker"
  "Prowlarr|prowlarr|9696|prowlarr|no|docker"
  "qBittorrent (via Gluetun)|gluetun|8080|qbit|no|docker"
  "Radarr|radarr|7878|radarr|no|docker"
  "Sonarr|sonarr|8989|sonarr|no|docker"
  "Uptime Kuma|uptime-kuma|3001|status|yes|docker"
  "Vaultwarden|vaultwarden|80|vault|no|docker"
)

# Génère un bloc WebSocket
_ws_headers() {
  cat <<'EOF'
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection $http_connection;
proxy_http_version 1.1;
EOF
}

# Config pour un service exposé sur internet (HTTPS + domaine)
_conf_web() {
  local server="$1" port="$2" subdomain="$3" domain="$4" cert_name="$5" ws="$6" idx="$7"
  cat <<NGINX
# ------------------------------------------------------------
# ${subdomain}.${domain}
# ------------------------------------------------------------

map \$scheme \$hsts_header {
    https   "max-age=63072000; preload";
}

server {
  set \$forward_scheme http;
  set \$server         "${server}";
  set \$port           ${port};

  listen 80;
  listen [::]:80;
  listen 443 ssl;
  listen [::]:443 ssl;

  server_name ${subdomain}.${domain};
  http2 on;

  # Let's Encrypt SSL — certificat à créer manuellement dans l'UI NPM
  include conf.d/include/letsencrypt-acme-challenge.conf;
  include conf.d/include/ssl-cache.conf;
  include conf.d/include/ssl-ciphers.conf;
  ssl_certificate /etc/letsencrypt/live/${cert_name}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${cert_name}/privkey.pem;

  include conf.d/include/block-exploits.conf;
  include conf.d/include/force-ssl.conf;

NGINX

  [ "$ws" = "yes" ] && _ws_headers

  cat <<NGINX

  access_log /data/logs/proxy-host-${idx}_access.log proxy;
  error_log  /data/logs/proxy-host-${idx}_error.log warn;

  location / {
NGINX

  [ "$ws" = "yes" ] && cat <<NGINX
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$http_connection;
    proxy_http_version 1.1;
NGINX

  cat <<NGINX
    include conf.d/include/proxy.conf;
  }

  include /data/nginx/custom/server_proxy[.]conf;
}
NGINX
}

# Config pour un service local (HTTP uniquement, domaine local via /etc/hosts)
_conf_local() {
  local server="$1" port="$2" subdomain="$3" domain="$4" ws="$5" idx="$6"
  cat <<NGINX
# ------------------------------------------------------------
# ${subdomain}.${domain} — accès local uniquement
# ------------------------------------------------------------

server {
  set \$forward_scheme http;
  set \$server         "${server}";
  set \$port           ${port};

  listen 80;
  listen [::]:80;

  server_name ${subdomain}.${domain};

NGINX

  [ "$ws" = "yes" ] && _ws_headers

  cat <<NGINX

  access_log /data/logs/proxy-host-${idx}_access.log proxy;
  error_log  /data/logs/proxy-host-${idx}_error.log warn;

  location / {
NGINX

  [ "$ws" = "yes" ] && cat <<NGINX
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$http_connection;
    proxy_http_version 1.1;
NGINX

  cat <<NGINX
    include conf.d/include/proxy.conf;
  }

  include /data/nginx/custom/server_proxy[.]conf;
}
NGINX
}

step_npm() {
  header "4 / 5 — Proxy hosts Nginx Proxy Manager"
  load_env

  local dst_vol="${VOLUME_ROOT:-$HOME/docker-data}/npm/data/nginx/proxy_host"

  # ── Web ou local ────────────────────────────────────────────────────────────
  echo "  Comment accèdes-tu à tes services ?"
  echo
  echo "  1. Via un domaine public  (ex: jellyfin.mondomaine.com + HTTPS)"
  echo "  2. En local uniquement    (ex: jellyfin.homelab  → entrées /etc/hosts)"
  echo
  read -rp "$(echo -e "  ${CYAN}?${RESET} Mode ${DIM}[1]${RESET} : ")" net_mode
  net_mode="${net_mode:-1}"
  echo

  local domain="" cert_name="" machine_ip=""

  if [ "$net_mode" = "1" ]; then
    domain=$(ask "Domaine de base" "mondomaine.com")
    cert_name=$(ask "Nom du certificat dans NPM (à créer manuellement)" "npm-1")
    _NET_MODE="web"
  else
    domain=$(ask "Domaine local (suffixe)" "homelab")
    machine_ip=$(ask "IP locale de cette machine (ex: 192.168.1.10)" "127.0.0.1")
    _NET_MODE="local"
  fi
  _DOMAIN="$domain"

  # ── Sélection des services ─────────────────────────────────────────────────
  echo
  info "Services disponibles :"
  echo
  local i=1
  for svc in "${SERVICES[@]}"; do
    printf "  %2d. %s\n" "$i" "${svc%%|*}"
    ((i++))
  done
  echo
  echo -e "  ${DIM}Numéros séparés par espace, ou 'all' pour tous :${RESET}"
  read -rp "  > " selection

  local selected=()
  if [ "$selection" = "all" ] || [ -z "$selection" ]; then
    selected=("${SERVICES[@]}")
  else
    for num in $selection; do
      local idx=$((num - 1))
      if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#SERVICES[@]}" ]; then
        selected+=("${SERVICES[$idx]}")
      fi
    done
  fi

  # Nettoyage des anciennes configs avant génération
  mkdir -p "$dst_vol"
  rm -f "$dst_vol"/*.conf

  local conf_idx=1
  local hosts_entries=()

  for svc in "${selected[@]}"; do
    IFS='|' read -r name container port subdomain ws type <<< "$svc"
    local server="$container"

    if [ "$type" = "ip" ]; then
      server=$(ask "IP pour $name (Tailscale / réseau hôte)" "127.0.0.1")
      _ADGUARD_IP="$server"
    fi

    local conf_file="$dst_vol/${conf_idx}.conf"

    if [ "$net_mode" = "1" ]; then
      _conf_web "$server" "$port" "$subdomain" "$domain" "$cert_name" "$ws" "$conf_idx" \
        > "$conf_file"
      success "${subdomain}.${domain} → ${server}:${port}$([ "$ws" = "yes" ] && echo " [WS]")"
    else
      _conf_local "$server" "$port" "$subdomain" "$domain" "$ws" "$conf_idx" \
        > "$conf_file"
      hosts_entries+=("$machine_ip  ${subdomain}.${domain}")
      _HOSTS_ENTRIES+=("$machine_ip  ${subdomain}.${domain}")
      success "${subdomain}.${domain} → ${server}:${port}$([ "$ws" = "yes" ] && echo " [WS]")"
    fi

    ((conf_idx++))
  done

  success "$((conf_idx - 1)) configs générées → $dst_vol"

}

# ─────────────────────────────────────────────────────────────────────────────
# Étape 5 — Glance
# ─────────────────────────────────────────────────────────────────────────────
step_glance() {
  header "5 / 5 — Configuration de Glance"
  load_env

  local src="$SCRIPT_DIR/dc/glance/glance.yml"
  local dst="${VOLUME_ROOT:-$HOME/docker-data}/glance/config/glance.yml"

  if [ ! -f "$src" ]; then
    warn "glance.yml introuvable, étape ignorée."
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"

  # Domaine : utilise celui choisi à l'étape NPM si disponible, sinon demande
  local domain="${_DOMAIN:-}"
  if [ -z "$domain" ]; then
    domain=$(ask "Domaine utilisé pour les services" "godinlab.com")
  else
    info "Domaine : $domain  (repris de l'étape NPM)"
  fi

  # Substitution du domaine (godinlab.com → domaine choisi)
  _sed_inplace "s|godinlab\.com|${domain}|g" "$dst"

  # En mode local : les URL cliquables passent en http://
  if [ "${_NET_MODE:-}" = "local" ]; then
    _sed_inplace "s|url: https://|url: http://|g" "$dst"
    info "Mode local : URLs en http://"
  fi

  # IP d'AdGuard — reprise de l'étape NPM si disponible
  local adguard_ip="${_ADGUARD_IP:-127.0.0.1}"
  _sed_inplace "s|http://adguard-ip:8080|http://${adguard_ip}:8080|g" "$dst"

  success "glance.yml déployé → $dst"
}

# ─────────────────────────────────────────────────────────────────────────────
# Écriture /etc/hosts (mode local)
# ─────────────────────────────────────────────────────────────────────────────
_write_hosts() {
  [ "${#_HOSTS_ENTRIES[@]}" -eq 0 ] && return 0

  header "Entrées /etc/hosts"

  info "Les entrées suivantes sont nécessaires pour accéder aux services en local :"
  echo
  for entry in "${_HOSTS_ENTRIES[@]}"; do
    echo "    $entry"
  done
  echo

  if confirm "Écrire automatiquement dans /etc/hosts (sudo requis) ?" "y"; then
    local block="# Homelab"
    for entry in "${_HOSTS_ENTRIES[@]}"; do
      block+=$'\n'"$entry"
    done

    # Évite les doublons : supprime un bloc homelab existant puis réécrit
    if grep -q "# Homelab" /etc/hosts 2>/dev/null; then
      warn "Un bloc Homelab existe déjà dans /etc/hosts — il sera remplacé."
      sudo sed -i.bak '/# Homelab/,/^$/d' /etc/hosts
    fi

    echo "$block" | sudo tee -a /etc/hosts > /dev/null
    success "/etc/hosts mis à jour"
  else
    info "Pour l'ajouter manuellement :"
    echo "    sudo tee -a /etc/hosts << 'EOF'"
    echo "    # Homelab"
    for entry in "${_HOSTS_ENTRIES[@]}"; do
      echo "    $entry"
    done
    echo "    EOF"
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Wizard principal
# ─────────────────────────────────────────────────────────────────────────────
main() {
  clear
  echo -e "${BOLD}${BLUE}"
  echo "  ╔══════════════════════════════════════╗"
  echo "  ║       🏠  HOMELAB  SETUP  WIZARD     ║"
  echo "  ╚══════════════════════════════════════╝"
  echo -e "${RESET}"
  echo -e "  Ce wizard configure la stack du début à la fin."
  echo -e "  ${DIM}Ctrl+C à tout moment pour annuler.${RESET}"
  echo
  confirm "Commencer ?" "y" || exit 0

  step_check_deps
  press_enter; clear

  step_env
  press_enter; clear

  step_dirs
  press_enter; clear

  step_npm
  press_enter; clear

  step_glance
  press_enter; clear

  _write_hosts

  echo
  divider
  success "Configuration terminée !"
  divider
  echo
  info "Pour démarrer la stack :"
  echo "    docker compose up -d"
  echo
  info "Après le premier démarrage :"
  echo "    • Crée le certificat SSL dans l'UI NPM (si mode web)"
  echo "    • Patch qBittorrent : arrête le conteneur, modifie"
  echo "      qBittorrent.conf (CSRFProtection, HostHeaderValidation,"
  echo "      LocalHostAuthentication → false), puis redémarre"
  echo

  if confirm "Démarrer la stack maintenant ?" "y"; then
    cd "$SCRIPT_DIR"
    docker compose up -d
    echo
    success "Stack démarrée !"
    echo
    local scheme; [ "${_NET_MODE:-web}" = "local" ] && scheme="http" || scheme="https"
    local glance_url="${scheme}://glance.${_DOMAIN:-mondomaine.com}"
    info "Glance : ${BOLD}${glance_url}${RESET}"

  fi
}

main

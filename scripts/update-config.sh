#!/bin/bash

# MTProxy Config Auto-Update Script
# Downloads fresh configs from Telegram servers
# Safe to run while MTProxy is running - uses hot reload

set -euo pipefail

MTPROXY_DIR="/opt/mtproxy"
LOG_TAG="mtproxy-update"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$LOG_TAG] $1"
}

log "Starting config update..."

# Download new configs
log "Downloading proxy-secret..."
curl -s https://core.telegram.org/getProxySecret -o "${MTPROXY_DIR}/proxy-secret.new"

log "Downloading proxy-multi.conf..."
curl -s https://core.telegram.org/getProxyConfig -o "${MTPROXY_DIR}/proxy-multi.conf.new"

# Verify downloads
if [ ! -s "${MTPROXY_DIR}/proxy-secret.new" ]; then
    log "ERROR: proxy-secret.new is empty or download failed"
    exit 1
fi

if [ ! -s "${MTPROXY_DIR}/proxy-multi.conf.new" ]; then
    log "ERROR: proxy-multi.conf.new is empty or download failed"
    exit 1
fi

# Replace old configs
mv "${MTPROXY_DIR}/proxy-secret.new" "${MTPROXY_DIR}/proxy-secret"
mv "${MTPROXY_DIR}/proxy-multi.conf.new" "${MTPROXY_DIR}/proxy-multi.conf"

# Set correct ownership
chown mtproxy:mtproxy "${MTPROXY_DIR}/proxy-secret"
chown mtproxy:mtproxy "${MTPROXY_DIR}/proxy-multi.conf"

log "Config updated successfully"

# Signal MTProxy to reload (hot reload, no restart)
if systemctl is-active --quiet mtproxy; then
    log "Signaling MTProxy to reload config..."
    systemctl reload-or-restart mtproxy
    log "Reload signal sent"
else
    log "WARNING: MTProxy is not running"
fi

log "Config update completed"

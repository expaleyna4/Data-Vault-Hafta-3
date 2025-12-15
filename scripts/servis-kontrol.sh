#!/usr/bin/env bash
# DATA VAULT – Servis Durum Kontrolü

echo "=== DATA VAULT – SERVİS KONTROLÜ ($(date)) ==="
echo

# Samba servisleri
echo "[1] Samba Servisleri:"
for service in smbd nmbd; do
    if systemctl is-active --quiet $service; then
        echo "  ✓ $service: ÇALIŞIYOR"
    else
        echo "  ✗ $service: DURMUŞ"
    fi
done
echo

# Port kontrolü
echo "[2] Port Kontrolü:"
for port in 139 445; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo "  ✓ Port $port: DİNLENİYOR"
    else
        echo "  ✗ Port $port: KAPALI"
    fi
done
echo

# Paylaşım kontrolü
echo "[3] Samba Paylaşımları:"
smbclient -L localhost -N 2>/dev/null | grep -E "finans|ik|muhasebe|arge" || echo "  Paylaşım bulunamadı"
echo

# Son hatalar
echo "[4] Son 10 Dakikadaki Hatalar:"
journalctl -u smbd --since "10 minutes ago" -p err --no-pager 2>/dev/null | tail -n 5
[ $? -ne 0 ] && echo "  Hata bulunamadı"

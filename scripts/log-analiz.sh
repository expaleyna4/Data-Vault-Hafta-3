#!/usr/bin/env bash
# DATA VAULT – Samba Log Analizi

OUT="/var/log/samba-analiz-$(date +%Y%m%d).txt"

{
  echo "=== DATA VAULT – SAMBA LOG ANALİZİ ($(date)) ==="
  echo
  
  echo "[1] Son 24 Saatteki Tüm Loglar:"
  journalctl -u smbd --since "24 hours ago" --no-pager | tail -n 30
  echo
  
  echo "[2] Hata ve Uyarı Logları:"
  journalctl -u smbd --since "24 hours ago" -p warning --no-pager | tail -n 20
  echo
  
  echo "[3] Permission Denied Hataları:"
  journalctl -u smbd --since "24 hours ago" --no-pager | grep -i "permission\|denied" | tail -n 15
  echo
  
  echo "[4] Başarılı Bağlantılar:"
  journalctl -u smbd --since "24 hours ago" --no-pager | grep -i "connect" | tail -n 10
  echo
  
  echo "[5] Servis Durumu:"
  systemctl status smbd --no-pager | head -n 15
  
} > "$OUT"

echo "Log analizi tamamlandı: $OUT"

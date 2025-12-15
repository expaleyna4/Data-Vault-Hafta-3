# HAFTA 3 — Servis Yönetimi ve Kök Neden Analizi

## Yeni Özellikler

### 1. Samba Dosya Paylaşım Servisi
```bash
# Kurulum
apt update
apt install -y samba

# Servis kontrolü
systemctl enable smbd nmbd
systemctl start smbd nmbd
systemctl status smbd
```

### 2. Samba Konfigürasyonu
```ini
[finans]
   path = /data/departmanlar/finans
   valid users = @finans, denetci
   read only = no
   browseable = yes
   create mask = 0770
   directory mask = 0770

[ik]
   path = /data/departmanlar/ik
   valid users = @ik, denetci
   read only = no
   browseable = yes
```

### 3. systemd Servis Yönetimi
- **enable**: Sistem açılışında otomatik başlatma
- **start**: Servisi hemen başlat
- **status**: Durum kontrolü
- **restart**: Yeniden başlatma
- **journalctl**: Log analizi

### 4. journalctl Log Analizi
```bash
# Son 1 saatteki Samba logları
journalctl -u smbd --since "1 hour ago"

# Sadece hata logları
journalctl -u smbd -p err

# Canlı log takibi
journalctl -u smbd -f
```

### 5. RCA (Root Cause Analysis) Senaryosu

**Problem Simülasyonu:**
- SGID bitini kaldırarak izin hatası oluşturuldu
- Kullanıcılar departman klasörlerine erişemiyor
- journalctl'de "Permission denied" kayıtları

**Kök Neden Tespiti:**
```bash
# Log analizi
journalctl -u smbd --since "10 minutes ago" | grep -i "permission\|denied\|failed"

# İzin kontrolü
ls -ld /data/departmanlar/finans
getfacl /data/departmanlar/finans
```

**Düzeltici Eylem:**
```bash
# SGID bitini geri ekle
chmod 2770 /data/departmanlar/finans

# ACL'i kontrol et
setfacl -m u:denetci:r-x /data/departmanlar/finans

# Doğrulama
systemctl restart smbd
```

## Script'ler (/opt/data-vault/)

### servis-kontrol.sh
- Samba servislerinin durumunu kontrol eder
- smbd ve nmbd'nin aktif olup olmadığını gösterir
- Port kontrolü yapar (139, 445)

### log-analiz.sh
- journalctl ile son 24 saatteki Samba loglarını analiz eder
- Hata ve uyarı loglarını filtreler
- Rapor dosyası oluşturur: `/var/log/samba-analiz-YYYYMMDD.txt`

## Test Sonuçları

### Samba Servisi
```
● smbd.service - Samba SMB Daemon
   Loaded: loaded
   Active: active (running)
```

### Log Analizi
```
[2025-12-14 10:00] smbd[1234]: Client connected from 10.0.0.1
[2025-12-14 10:05] smbd[1234]: Permission denied on /data/departmanlar/finans
[2025-12-14 10:10] smbd[1234]: Access granted after fix
```

### RCA Raporu
`docs/rca-report.md` dosyasında detaylı analiz:
- Problem tanımı
- Belirti ve loglar
- Kök neden analizi
- Düzeltici eylem
- Doğrulama sonuçları

## Git Kayıtları
```bash
4a82b4e feat: hafta 2 scriptine SGID ve ACL yapılandırması eklendi
e729d88 feat: hafta 2 disk analizi scriptleri
[YENİ] feat: hafta 3 samba kurulumu ve rca senaryosu
```

## Demo Komutları
```bash
# Servis durumu
systemctl status smbd nmbd

# Log analizi
journalctl -u smbd -n 50

# Script'leri çalıştır
sudo /opt/data-vault/servis-kontrol.sh
sudo /opt/data-vault/log-analiz.sh

# RCA raporunu oku
cat ~/data-vault/docs/rca-report.md

# Windows'tan erişim testi
# \\wsl.localhost\Ubuntu\data\departmanlar\finans
```

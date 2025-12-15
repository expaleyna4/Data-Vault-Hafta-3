# DATA VAULT - HAFTA 3

## 🎯 Hızlı Başlangıç

Bu paket Hafta 3 gereksinimlerini içerir:
- ✅ Samba dosya paylaşım servisi
- ✅ systemd servis yönetimi
- ✅ journalctl log analizi
- ✅ RCA (Root Cause Analysis) senaryosu

## ⚠️ Önkoşullar

**HAFTA 1 ve 2 KURULU OLMALI!**

```bash
# Kontrol:
ls -ld /data/departmanlar/finans /data/departmanlar/ik
# SGID biti (drwxrws---+) olmalı
```

## 🚀 Kurulum (3 Dakika)

### Adım 1: WSL Ubuntu'ya Gir
```bash
wsl -d Ubuntu
```

### Adım 2: Script'i Kopyala
```bash
cp /mnt/c/Users/KULLANICI_ADI/Masaüstü/data-vault-3/kurulum-hafta3.sh ~/
chmod +x ~/kurulum-hafta3.sh
```

### Adım 3: Çalıştır
```bash
bash ~/kurulum-hafta3.sh
```

Script şunları yapar:
1. ✅ Samba kurulumu (apt install)
2. ✅ Konfigürasyon (/etc/samba/smb.conf)
3. ✅ Kullanıcı şifreleri (smbpasswd)
4. ✅ systemd servisleri (enable + start)
5. ✅ RCA senaryosu (hata simülasyonu + düzeltme)
6. ✅ Git commit

## 🧪 Test (Otomatik)

```bash
cp /mnt/c/Users/KULLANICI_ADI/Masaüstü/data-vault-3/test-hafta3.sh ~/
chmod +x ~/test-hafta3.sh
bash ~/test-hafta3.sh
```

### Test Kapsamı (15 Test)
1. ✅ Samba paket kurulumu
2. ✅ smbd servis durumu
3. ✅ nmbd servis durumu
4. ✅ Otomatik başlatma (enable)
5. ✅ Port 445 kontrolü
6. ✅ Port 139 kontrolü
7. ✅ smb.conf dosyası
8. ✅ Samba paylaşımları (4 departman)
9. ✅ Samba kullanıcıları
10. ✅ SGID izinleri
11. ✅ ACL yetkileri
12. ✅ journalctl log erişimi
13. ✅ servis-kontrol.sh scripti
14. ✅ log-analiz.sh scripti
15. ✅ RCA raporu

## 📊 Manuel Test Komutları

```bash
# Servis durumu
sudo systemctl status smbd nmbd

# Paylaşım listesi
smbclient -L localhost -N

# Log analizi
sudo journalctl -u smbd -n 50

# Scriptler
sudo /opt/data-vault/servis-kontrol.sh
sudo /opt/data-vault/log-analiz.sh

# RCA raporu
cat ~/data-vault/docs/rca-report.md

# İzin kontrolü
ls -ld /data/departmanlar/*
getfacl /data/departmanlar/finans
```

## 📁 Dosya Yapısı

```
data-vault-3/
├── kurulum-hafta3.sh           # Otomatik kurulum
├── test-hafta3.sh              # 15 test senaryosu
├── HOCAYA_SUNUM_3.md          # Sunum dokümanı
├── SISTEM_DURUMU_3.json       # Sistem durumu
├── config/
│   └── smb.conf               # Samba konfigürasyonu
├── docs/
│   └── rca-report.md          # RCA analiz raporu
└── scripts/
    ├── servis-kontrol.sh      # Servis durum kontrolü
    └── log-analiz.sh          # journalctl log analizi
```

## 🔧 Yeni Özellikler (Hafta 1-2'den Farklar)

### Samba Dosya Paylaşımı
- finans, ik, muhasebe, arge paylaşımları
- Grup tabanlı erişim kontrolü
- SMB2/SMB3 protokol desteği

### systemd Servis Yönetimi
- enable/start/status/restart komutları
- Otomatik başlatma yapılandırması
- Servis durum izleme

### journalctl Log Analizi
- Zaman bazlı filtreleme (--since)
- Hata seviyesi filtreleme (-p err)
- Canlı log takibi (-f)
- Rapor oluşturma

### RCA (Root Cause Analysis)
- Simüle edilmiş izin hatası
- 5 Why metodolojisi
- Düzeltici eylem
- Detaylı dokümantasyon

## 🎓 Teknolojiler

- **Samba**: Dosya ve yazıcı paylaşım servisi
- **systemctl**: systemd servis yönetimi
- **journalctl**: systemd log görüntüleme
- **smbclient**: Samba istemci aracı
- **testparm**: Samba konfigürasyon test
- **pdbedit**: Samba kullanıcı yönetimi

## 🆘 Sorun Giderme

### Samba başlatılamıyor
```bash
# Konfigürasyon kontrolü
sudo testparm

# Log kontrolü
sudo journalctl -u smbd -n 50

# Port kontrolü
sudo netstat -tuln | grep -E "445|139"
```

### Paylaşımlar görünmüyor
```bash
# Paylaşım listesi
smbclient -L localhost -N

# Konfigürasyon testi
sudo testparm -s
```

### İzin hatası
```bash
# SGID kontrolü
ls -ld /data/departmanlar/*

# ACL kontrolü
getfacl /data/departmanlar/finans

# Düzeltme
sudo chmod 2770 /data/departmanlar/finans
sudo setfacl -m u:denetci:r-x /data/departmanlar/finans
```

## 📚 Dokümantasyon

- **BAŞLAT_BENİ_OKU.txt**: Hızlı başlangıç
- **HOCAYA_SUNUM_3.md**: Sunum için özet
- **KURULUM_3.md**: Detaylı kurulum adımları
- **TEST_3.md**: Test senaryoları
- **docs/rca-report.md**: RCA analiz raporu

## 📦 Paket İçeriği

- Tüm scriptler çalıştırılabilir (chmod +x)
- Git history korunmuş (Hafta 1→2→3)
- Otomatik kurulum + test
- Detaylı dokümantasyon

## ✅ Başarı Kriterleri

1. ✅ Samba kurulu ve çalışıyor
2. ✅ 4 departman paylaşımı aktif
3. ✅ systemd servisleri otomatik başlıyor
4. ✅ journalctl logları okunabiliyor
5. ✅ RCA senaryosu belgelenmiş
6. ✅ Tüm testler geçiyor (15/15)

## 🎉 Başarı!

Hafta 3 kurulumu tamamlandı!

```bash
# Son kontrol
sudo systemctl status smbd
smbclient -L localhost -N
```

---

**Lisans:** GNU GPLv3  
**Proje:** Data Vault - Departman Dosya Sunucusu  
**Hafta:** 3 - Servis Yönetimi ve RCA

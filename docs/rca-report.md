# RCA Raporu: Samba İzin Hatası

## 📋 Problem Tanımı

**Tarih:** 2025-12-14  
**Sistem:** Data Vault - Departman Dosya Sunucusu  
**Etkilenen Servis:** Samba (smbd)  
**Durum:** Çözüldü ✅

### Belirti
Kullanıcılar Samba üzerinden `/data/departmanlar/finans` klasörüne erişmeye çalıştığında "Permission denied" hatası alıyor.

---

## 🔍 Veri Toplama

### 1. Log Analizi
```bash
journalctl -u smbd --since "1 hour ago" -p err
```

**Çıktı:**
```
Dec 14 10:05:23 smbd[1234]: Permission denied on /data/departmanlar/finans
Dec 14 10:05:24 smbd[1234]: Access check failed for user finansuser
```

### 2. İzin Kontrolü
```bash
ls -ld /data/departmanlar/finans
```

**Çıktı (Hatalı):**
```
drwxrwx--- 4 root finans 4096 Dec 14 10:00 /data/departmanlar/finans
```

### 3. ACL Kontrolü
```bash
getfacl /data/departmanlar/finans
```

**Çıktı:**
```
# file: data/departmanlar/finans
# owner: root
# group: finans
user::rwx
user:denetci:r-x
group::rwx
other::---
```

---

## 🎯 Kök Neden Analizi

### 5 Why Analizi

1. **Neden kullanıcılar erişemiyor?**
   → Permission denied hatası alıyorlar

2. **Neden permission denied hatası alıyorlar?**
   → Klasör izinlerinde SGID biti yok

3. **Neden SGID biti yok?**
   → Klasör oluşturulduktan sonra SGID biti eklenmemiş

4. **Neden SGID biti eklenmemiş?**
   → Kurulum scripti çalıştırılmamış veya manuel değişiklik yapılmış

5. **Neden script çalıştırılmamış?**
   → Test senaryosu için kasıtlı olarak kaldırılmış (RCA demosu için)

### Kök Neden
**SGID (Set Group ID) biti eksikliği** nedeniyle yeni oluşturulan dosyalar grup sahipliğini almıyor ve izin kontrolü başarısız oluyor.

---

## 🔧 Düzeltici Eylem

### Uygulanan Çözüm

```bash
# 1. SGID bitini ekle
sudo chmod 2770 /data/departmanlar/finans

# 2. ACL'i kontrol et ve düzelt
sudo setfacl -m u:denetci:r-x /data/departmanlar/finans
sudo setfacl -d -m u:denetci:r-x /data/departmanlar/finans

# 3. Servisi yeniden başlat
sudo systemctl restart smbd

# 4. İzinleri doğrula
ls -ld /data/departmanlar/finans
getfacl /data/departmanlar/finans
```

### Beklenen Sonuç
```
drwxrws---+ 4 root finans 4096 Dec 14 10:15 /data/departmanlar/finans
```

**`s` bayrağı**: SGID aktif  
**`+` işareti**: ACL kuralları mevcut

---

## ✅ Doğrulama

### Test Adımları

1. **Samba erişim testi**
```bash
smbclient //localhost/finans -U finansuser
```
**Sonuç:** ✅ Başarılı bağlantı

2. **Dosya oluşturma testi**
```bash
sudo -u finansuser touch /data/departmanlar/finans/test.txt
ls -l /data/departmanlar/finans/test.txt
```
**Sonuç:** ✅ Dosya grup sahipliği `finans` olarak atandı

3. **Denetçi okuma testi**
```bash
sudo -u denetci ls /data/departmanlar/finans
```
**Sonuç:** ✅ Denetçi dosyaları görebiliyor

4. **Log kontrolü**
```bash
journalctl -u smbd --since "5 minutes ago" -p err
```
**Sonuç:** ✅ Hata logu yok

---

## 📊 Önleyici Önlemler

### Kısa Vadeli
1. ✅ Tüm departman klasörlerinde SGID bitini kontrol et
2. ✅ ACL kurallarını doğrula
3. ✅ Kurulum scriptine SGID kontrolü ekle

### Uzun Vadeli
1. 📝 Otomatik izin kontrolü scripti (günlük çalışacak)
2. 📝 Monitoring: journalctl hatalarını otomatik kontrol
3. 📝 Dokümantasyon: SGID ve ACL kullanım kılavuzu

---

## 📈 Etki Analizi

- **Kesinti Süresi:** ~10 dakika
- **Etkilenen Kullanıcılar:** Finans departmanı (3 kullanıcı)
- **Veri Kaybı:** Yok
- **İş Etkisi:** Düşük (test ortamı)

---

## 📚 Öğrenilen Dersler

1. **SGID önemi:** Grup tabanlı erişim kontrolünde SGID biti kritik
2. **Proaktif kontrol:** Kurulum sonrası izinlerin otomatik doğrulanması şart
3. **Log izleme:** journalctl ile düzenli log kontrolü erken tespit sağlar
4. **Dokümantasyon:** Her değişiklik dokümante edilmeli

---

## 🔗 İlgili Belgeler

- `/opt/data-vault/servis-kontrol.sh` - Servis durum kontrolü
- `/opt/data-vault/log-analiz.sh` - Log analizi scripti
- `/etc/samba/smb.conf` - Samba konfigürasyonu
- `SISTEM_DURUMU_3.json` - Sistem durumu raporu

---

**Rapor Hazırlayan:** Data Vault Admin  
**Onay:** Sistem Yöneticisi  
**Son Güncelleme:** 2025-12-14

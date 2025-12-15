#!/bin/bash
# DATA VAULT - HAFTA 3 - Otomatik Test Scripti
# Servis Yönetimi ve Kök Neden Analizi Testleri

echo "======================================"
echo "  DATA VAULT - HAFTA 3 TEST"
echo "======================================"
echo ""
echo "⏱️  Test başlıyor..."
echo ""
sleep 1

# If dpkg (Debian utilities) are missing, instruct Windows users to run via WSL
if ! command -v dpkg >/dev/null 2>&1; then
    echo "\n[ERROR] dpkg bulunamadı — bu testler Debian/Ubuntu (ör. WSL) ortamı gerektirir."
    if command -v wsl.exe >/dev/null 2>&1; then
        echo "PowerShell üzerinden çalıştırmak için: .\\run-test.ps1"
        echo "veya WSL içinde: wsl bash -c \"cd '$(pwd)' && bash ./test-hafta3.sh\""
    else
        echo "WSL kurulu değil veya erişilebilir değil. Lütfen WSL kurun veya script'i Linux'ta çalıştırın."
    fi
    exit 1
fi

# Detect sudo availability and running user
if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# Test sayaçları
PASSED=0
FAILED=0

# Test fonksiyonu
test_check() {
    if [ $? -eq 0 ]; then
        echo "  ✅ BAŞARILI"
        ((PASSED++))
    else
        echo "  ❌ BAŞARISIZ"
        ((FAILED++))
    fi
    echo ""
    read -p "Sonraki teste geçmek için Enter'a basın..." dummy
    echo ""
}

# Test 1: Samba paketi kurulu mu?
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 1/15] Samba Paket Kurulumu"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Samba paketinin sistemde kurulu olduğunu doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  dpkg -l | grep samba"
echo ""
echo "➤ Yanıt:"
${SUDO} dpkg -l | grep samba
echo ""
echo "# Açıklama: samba ve samba-common paketleri kurulu mu?"
${SUDO} dpkg -l | grep -q "^ii.*samba"
test_check

# Test 2: smbd servisi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 2/15] smbd Servis Durumu"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Samba SMB Daemon'ın aktif ve çalışır durumda olduğunu kontrol et"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  systemctl is-active smbd"
echo ""
echo "➤ Yanıt:"
${SUDO} systemctl is-active smbd
echo ""
echo "  systemctl status smbd"
echo ""
echo "➤ Yanıt:"
${SUDO} systemctl status smbd --no-pager | head -n 10
echo ""
echo "# Açıklama: smbd servisi 'active (running)' durumunda mı?"
${SUDO} systemctl is-active --quiet smbd
test_check

# Test 3: nmbd servisi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 3/15] nmbd Servis Durumu"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Samba NetBIOS Name Server'ın aktif olduğunu kontrol et"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  systemctl is-active nmbd"
echo ""
echo "➤ Yanıt:"
${SUDO} systemctl is-active nmbd
echo ""
echo "  systemctl status nmbd"
echo ""
echo "➤ Yanıt:"
${SUDO} systemctl status nmbd --no-pager | head -n 10
echo ""
echo "# Açıklama: nmbd servisi 'active (running)' durumunda mı?"
${SUDO} systemctl is-active --quiet nmbd
test_check

# Test 4: Otomatik başlatma
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 4/15] Otomatik Başlatma (enable)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Samba servislerinin sistem açılışında otomatik başladığını doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  systemctl is-enabled smbd"
echo "  systemctl is-enabled nmbd"
echo ""
echo "➤ Yanıt:"
${SUDO} systemctl is-enabled smbd
${SUDO} systemctl is-enabled nmbd
echo ""
echo "# Açıklama: Her iki servis de 'enabled' durumunda mı?"
${SUDO} systemctl is-enabled --quiet smbd && ${SUDO} systemctl is-enabled --quiet nmbd
test_check

# Test 5: Port kontrolü (445)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 5/15] SMB Port Kontrolü (445)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Samba'nın SMB portu (445) üzerinden dinlediğini kontrol et"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  netstat -tuln | grep :445"
echo ""
echo "➤ Yanıt:"
${SUDO} netstat -tuln 2>/dev/null | grep :445 || ss -tuln 2>/dev/null | grep :445
echo ""
echo "# Açıklama: Port 445 LISTEN durumunda mı?"
${SUDO} netstat -tuln 2>/dev/null | grep -q ":445 " || ss -tuln 2>/dev/null | grep -q ":445 "
test_check

# Test 6: Port kontrolü (139)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 6/15] NetBIOS Port Kontrolü (139)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Samba'nın NetBIOS portu (139) üzerinden dinlediğini kontrol et"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  netstat -tuln | grep :139"
echo ""
echo "➤ Yanıt:"
${SUDO} netstat -tuln 2>/dev/null | grep :139 || ss -tuln 2>/dev/null | grep :139
echo ""
echo "# Açıklama: Port 139 LISTEN durumunda mı?"
${SUDO} netstat -tuln 2>/dev/null | grep -q ":139 " || ss -tuln 2>/dev/null | grep -q ":139 "
test_check

# Test 7: Samba konfigürasyon dosyası
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 7/15] Samba Konfigürasyon Dosyası"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: /etc/samba/smb.conf dosyasının varlığını ve içeriğini kontrol et"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  ls -l /etc/samba/smb.conf"
echo ""
echo "➤ Yanıt:"
${SUDO} ls -l /etc/samba/smb.conf 2>&1
echo ""
echo "  testparm -s 2>&1 | head -n 20"
echo ""
echo "➤ Yanıt (Konfigürasyon Özeti):"
${SUDO} testparm -s 2>&1 | head -n 20
echo ""
echo "# Açıklama: smb.conf dosyası mevcut ve geçerli mi?"
[ -f /etc/samba/smb.conf ] && ${SUDO} testparm -s >/dev/null 2>&1
test_check

# Test 8: Samba paylaşımları
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 8/15] Samba Paylaşım Listesi"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: finans, ik, muhasebe, arge paylaşımlarının tanımlı olduğunu doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  smbclient -L localhost -N"
echo ""
echo "➤ Yanıt:"
${SUDO} smbclient -L localhost -N 2>&1 | grep -E "finans|ik|muhasebe|arge|Sharename"
echo ""
echo "# Açıklama: 4 departman paylaşımı (finans, ik, muhasebe, arge) görünüyor mu?"
${SUDO} smbclient -L localhost -N 2>&1 | grep -q "finans" && \
${SUDO} smbclient -L localhost -N 2>&1 | grep -q "ik" && \
${SUDO} smbclient -L localhost -N 2>&1 | grep -q "muhasebe" && \
${SUDO} smbclient -L localhost -N 2>&1 | grep -q "arge"
test_check

# Test 9: Samba kullanıcıları
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 9/15] Samba Kullanıcı Listesi"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: finansuser, ikuser, denetci kullanıcılarının Samba'da tanımlı olduğunu kontrol et"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  sudo pdbedit -L"
echo ""
echo "➤ Yanıt:"
[ ${SUDO} ] && ${SUDO} pdbedit -L 2>&1 || pdbedit -L 2>&1
echo ""
echo "# Açıklama: 3 kullanıcı (finansuser, ikuser, denetci) Samba'da kayıtlı mı?"
${SUDO} pdbedit -L 2>/dev/null | grep -q "finansuser" && \
${SUDO} pdbedit -L 2>/dev/null | grep -q "ikuser" && \
${SUDO} pdbedit -L 2>/dev/null | grep -q "denetci"
test_check

# Test 10: SGID izinleri
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 10/15] SGID İzin Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Departman klasörlerinde SGID bitinin aktif olduğunu doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  ls -ld /data/departmanlar/*"
echo ""
echo "➤ Yanıt:"
${SUDO} ls -ld /data/departmanlar/* 2>&1
echo ""
echo "# Açıklama: Her klasörde 's' bayrağı (drwxrws---) var mı?"
${SUDO} ls -ld /data/departmanlar/finans 2>/dev/null | grep -q "drwxrws" && \
${SUDO} ls -ld /data/departmanlar/ik 2>/dev/null | grep -q "drwxrws" && \
${SUDO} ls -ld /data/departmanlar/muhasebe 2>/dev/null | grep -q "drwxrws" && \
${SUDO} ls -ld /data/departmanlar/arge 2>/dev/null | grep -q "drwxrws"
test_check

# Test 11: ACL kontrolü
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 11/15] ACL Yetki Kontrolü"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Denetçi kullanıcısının ACL ile r-x yetkisine sahip olduğunu doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  getfacl /data/departmanlar/finans"
echo ""
echo "➤ Yanıt:"
${SUDO} getfacl /data/departmanlar/finans 2>&1 | grep -E "user::rwx|user:denetci:r-x|group::rwx|mask::rwx"
echo ""
echo "# Açıklama: 'user:denetci:r-x' satırı mevcut mu?"
${SUDO} getfacl /data/departmanlar/finans 2>/dev/null | grep -q "user:denetci:r-x"
test_check

# Test 12: journalctl log erişimi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 12/15] journalctl Log Erişimi"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: journalctl ile Samba loglarına erişilebildiğini doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  journalctl -u smbd -n 10 --no-pager"
echo ""
echo "➤ Yanıt (Son 10 satır):"
${SUDO} journalctl -u smbd -n 10 --no-pager 2>&1
echo ""
echo "# Açıklama: journalctl logları okunabiliyor mu?"
${SUDO} journalctl -u smbd -n 1 --no-pager >/dev/null 2>&1
test_check

# Test 13: servis-kontrol.sh scripti
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 13/15] servis-kontrol.sh Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Servis kontrol scriptinin varlığını ve çalıştırılabilir olduğunu doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  ls -l /opt/data-vault/servis-kontrol.sh"
echo ""
echo "➤ Yanıt:"
${SUDO} ls -l /opt/data-vault/servis-kontrol.sh 2>&1
echo ""
echo "  sudo /opt/data-vault/servis-kontrol.sh"
echo ""
echo "➤ Yanıt:"
${SUDO} /opt/data-vault/servis-kontrol.sh 2>&1
echo ""
echo "# Açıklama: Script mevcut, çalıştırılabilir ve hatasız çalışıyor mu?"
[ -x /opt/data-vault/servis-kontrol.sh ] && ${SUDO} /opt/data-vault/servis-kontrol.sh >/dev/null 2>&1
test_check

# Test 14: log-analiz.sh scripti
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 14/15] log-analiz.sh Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Log analiz scriptinin varlığını ve çalışabilirliğini doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  ls -l /opt/data-vault/log-analiz.sh"
echo ""
echo "➤ Yanıt:"
${SUDO} ls -l /opt/data-vault/log-analiz.sh 2>&1
echo ""
echo "  sudo /opt/data-vault/log-analiz.sh"
echo ""
echo "➤ Yanıt:"
${SUDO} /opt/data-vault/log-analiz.sh 2>&1 | tail -n 5
echo ""
echo "# Rapor dosyası oluşturuldu mu?"
LOG_FILE="/var/log/samba-analiz-$(date +%Y%m%d).txt"
echo "  ${SUDO} ls -lh $LOG_FILE"
${SUDO} ls -lh "$LOG_FILE" 2>&1
echo ""
echo "# Açıklama: Script çalışıyor ve rapor dosyası oluşturuluyor mu?"
[ -x /opt/data-vault/log-analiz.sh ] && ${SUDO} [ -f "$LOG_FILE" ]
test_check

# Test 15: RCA raporu
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[TEST 15/15] RCA Rapor Belgesi"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "# Amaç: Kök Neden Analizi raporunun oluşturulduğunu doğrula"
echo ""
echo "➤ Çalıştırılan Komut:"
echo "  ls -l ~/data-vault/docs/rca-report.md"
echo ""
echo "➤ Yanıt:"
${SUDO} ls -l ~/data-vault/docs/rca-report.md 2>&1
echo ""
echo "  head -n 20 ~/data-vault/docs/rca-report.md"
echo ""
echo "➤ Yanıt (İlk 20 satır):"
${SUDO} head -n 20 ~/data-vault/docs/rca-report.md 2>&1
echo ""
echo "# Açıklama: RCA raporu mevcut ve içerik dolu mu?"
[ -f ~/data-vault/docs/rca-report.md ] && [ -s ~/data-vault/docs/rca-report.md ]
test_check

# Özet
echo ""
echo "======================================"
echo "  TEST ÖZET"
echo "======================================"
echo ""
echo "✅ Başarılı: $PASSED"
echo "❌ Başarısız: $FAILED"
echo "📊 Toplam: $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 TÜM TESTLER BAŞARILI!"
    echo ""
    echo "Hafta 3 kurulumu tamamlandı ve çalışıyor."
    echo "Samba servisleri aktif ve yapılandırma doğru."
else
    echo "⚠️  BAZI TESTLER BAŞARISIZ!"
    echo ""
    echo "Lütfen hata mesajlarını inceleyin."
    echo "Kurulum scriptini tekrar çalıştırmanız gerekebilir."
fi

echo ""
echo "======================================"

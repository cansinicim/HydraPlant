---
description: docs/05'ten bir hikâyeyi uçtan uca uygula (plan → test → kod → doğrula)
argument-hint: <hikaye-id> (örn. E4.4)
---

$1 hikâyesini uygula.

1. `docs/05-backlog.md`'de **$1**'i bul. Gherkin kabul kriterlerini oku.
2. Hikâyenin referansladığı spec bölümlerini oku (`docs/01`–`docs/04`, `docs/07`).
3. **Plan sun ve dur. Kod yazma.** Şunları listele:
   - Dokunacağın dosyalar
   - Yazacağın testler (her kabul kriteri için en az bir tane)
   - Bir SG kuralına dokunuyor mu? Dokunuyorsa hangisi?
   - Public API değişiyor mu? Yeni kullanıcı metni var mı?
4. Onay aldıktan sonra: **önce testler, sonra uygulama.**
5. `./scripts/verify.sh` → hepsi yeşil olmalı.
6. `docs/06`'daki DoD listesini tek tek işaretle.
   Doğrulayamadığın maddeyi "cihazda doğrulanmalı" diye işaretle — "yaptım" deme.
7. Conventional Commit, `Refs: $1` satırıyla.

Belirsizlik varsa varsayım yapma, sor. Spesifikasyon zaten yazılı; tahmin etmeye gerek yok.

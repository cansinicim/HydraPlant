---
description: Tüm sağlık güvenliği kurallarını (SG-01…SG-08) denetle ve raporla
---

`docs/01-teknik-dokumantasyon.md` §7.4'teki SG-01…SG-08 kurallarının her biri için:

1. Kuralın kodda nerede uygulandığını bul (dosya + satır).
2. Kuralı doğrulayan testi bul. Testin `.disabled()` olmadığını doğrula.
3. Testi çalıştır ve sonucu göster.
4. Uygulanmamış veya testi olmayan kuralı **P0 hata** olarak raporla.

Sonucu tablo ver: `SG-xx | uygulama (dosya:satır) | test | durum`.

**Hiçbir şeyi düzeltme — sadece raporla.** Düzeltme ayrı bir görevdir ve onay ister.

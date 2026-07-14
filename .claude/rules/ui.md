---
paths: ["Features/**", "Packages/HydraUI/**", "Widgets/**", "Watch/**"]
---

# UI kuralları

`docs/03` (ekran durumları) ve `docs/04` (tasarım sistemi) bağlayıcıdır.

## Zorunlu
- Renk: `HydraColor.*`. Sabit hex veya `Color(red:...)` yasak.
- Font: `HydraFont.*`. `.font(.system(size: 17))` yasak.
- Boşluk: `HydraSpacing.*` (4/8/16/24/40). Ara değer yok — `padding(12)` yasak.
- Sayı gösteren her `Text` → `HydraFont.numeral` (tabular figures; yoksa halkadaki sayı titrer).
- Dokunma hedefi ≥ 44×44 pt, istisnasız.
- Kullanıcı metni → `String(localized:)`, anahtar `docs/07`'de tanımlı olmalı.
- Her `View` için `#Preview`, `Stub*` servisleriyle.

## Ekran yaparken
`docs/03`'te o ekranın **durum tablosunu** aç ve listelenen her durumu uygula.
Tabloda olmayan bir durum gösteriyorsan bu bir hatadır.
Tabloda olup uygulamadığın bir durum varsa bu da bir hatadır.

## Yasak (docs/04 §Yapılmayacaklar listesi)
- Solmuş / kahverengi / ölü bitki görseli. Varlık listesinde bile bulunmaz.
- Kırmızı hata rengi (yıkıcı eylemler hariç). `caution` amber'dır.
- "fail", "missed", "forgot", "only", "just" kelimeleri.
- `progress > 1.5` iken `InfoCard(tone: .celebration)`, konfeti veya haptik. (SG-02)
- Widget'ta animasyon (30 MB bellek limiti).
- Paywall'da geri sayım, sahte indirim, gecikmeli X butonu.

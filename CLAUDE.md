# HydraPlant

iOS su & elektrolit takip uygulaması. Swift 6 / SwiftUI. Backend yok.

Tam spesifikasyon `docs/` altındadır. **Kod yazmadan önce ilgili dokümanı oku.**

| Ne yapıyorsan | Önce oku |
|---|---|
| Herhangi bir şey | `docs/01-teknik-dokumantasyon.md` §3 (ADR) |
| Motor / hesaplama | `docs/01` §6 ve §7 — **spesifikasyon kaynaktır, kod değil** |
| Yeni public API | `docs/02-paket-arayuzleri.md` |
| Ekran / durum | `docs/03-ekran-ve-akis-spesifikasyonu.md` |
| Renk / font / boşluk | `docs/04-tasarim-sistemi.md` |
| Ne yapılacak | `docs/05-backlog.md` |
| Git / PR / test | `docs/06-muhendislik-standartlari.md` |
| Kullanıcı metni | `docs/07-metin-katalogu.md` |

---

## Değişmezler

1. **`HydraEngine` saftır.** `SwiftUI`, `HealthKit`, `WeatherKit`, `CloudKit`, `SwiftData`, `StoreKit` import edilemez.
2. **Kullanıcı verisi hiçbir sunucuya gitmez.** Üçüncü taraf analitik/çökme SDK'sı (Firebase, Sentry, Crashlytics, RevenueCat, Amplitude, Mixpanel) eklenmez.
3. **CloudKit şeması S1 sonunda dondurulur.** Sonrasında yalnızca alan *ekleme*.
4. **`@Model` sınıfları `HydraData` dışına çıkmaz.** Public imzalar `Sendable` DTO döndürür.

Bu dördü ADR gerektirir. `docs/01` §3'e bakmadan değiştirme.

---

## Sağlık güvenliği (SG kuralları)

`SAFETY-CRITICAL` yorumu taşıyan satırlar ve `Packages/HydraEngine/` altındaki güvenlik testleri **hook ile korunuyor.** Değiştirmeye çalışırsan engellenirsin. Bu kasıtlıdır.

Bu kodun hedef kitlesi arasında sıcakta çalışan işçiler ve dayanıklılık sporcuları var. Yanlış bir hidrasyon hedefi teorik bir hata değil. Şu üçü asla gevşetilmez:

- `finalML` her zaman `1600...6000` (hiponatremi riski)
- `hasMedicalCaution == true` → hedef sabit 2000 ml, elektrolit önerisi `nil`
- `progress > 1.5` → kutlama yok, konfeti yok, haptik yok

Bir SG kuralına dokunman gerektiğini düşünüyorsan **dur ve sor.** Kendi başına ilerleme.

---

## Kod kuralları

- Swift 6 strict concurrency, `-warnings-as-errors`
- Force unwrap (`!`), `try!`, `fatalError` yasak — testler ve `HydraPlantApp.swift` hariç
- `print()` yasak — `Logger` (OSLog)
- Sabit sayı yasak — `HydraSpacing`, `Constants.swift`
- Sabit renk/font boyutu yasak — `HydraColor`, `HydraFont`
- Kullanıcıya görünen her metin `String(localized:)` — anahtar `docs/07`'de olmalı
- Sayı gösteren her `Text` → `HydraFont.numeral` (tabular figures)
- `final class` varsayılan; `public` gerekçe ister

## Test kuralları

- Swift Testing (`@Test`, `#expect`). XCTest yalnızca UI testlerinde.
- **Her kabul kriteri için bir test.** Testsiz hikâye "Done" değildir.
- Motor kapsamı ≥ %95. Data ≥ %80.
- Test isimleri cümle gibi: `computesBaseGoalForSedentaryAdult()`
- Test verisi `TestFixtures`'tan anlamlı isimlerle: `phoenixConstructionWorker`, `corruptedWeightInput`

## Git

- Dallar: `feat/e4-4-safety-ceiling`, `fix/...`, `chore/...`
- Commit: Conventional Commits, **İngilizce**, `Refs: E4.4` satırı zorunlu
- PR max **400 satır** üretim kodu diff'i
- Doküman kodla aynı PR'da güncellenir

Kod, commit ve kod içi yorumlar İngilizce. Dokümantasyon Türkçe.

---

## Çalışma şekli

**Bir seferde bir hikâye.** `docs/05`'ten hikâye ID'si (E4.4 gibi) verilir. Şunu yaparsın:

1. Hikâyenin Gherkin kabul kriterlerini oku
2. İlgili spec bölümünü oku
3. **Plan sun, onay bekle** (kod yazma)
4. Önce testleri yaz, sonra uygulamayı
5. `./scripts/verify.sh` çalıştır — hepsi yeşil olmalı
6. Commit et

Belirsizlik varsa varsayım yapma, sor.

## Bilmen gerekenler

- Xcode derlemesi: `./scripts/verify.sh` (lint + import kontrolü + testler)
- HealthKit, WeatherKit ve Live Activity **simülatörde tam çalışmaz.** Bu yüzeylere dokunan kodu "test ettim" deme; "cihazda doğrulanmalı" de.
- WeatherKit yetkilendirmesi aktif olmayabilir — `StubWeatherProvider` ile geliştir.
- Her protokolün bir `Stub` uygulaması olmak zorunda. Eksikse PR reddedilir.

## Bu makine (geliştirme ortamı notu)

Bu ortamda **tam Xcode yok, yalnızca Command Line Tools var.** Sonuç:
- Saf SPM paketleri (`HydraCore`, `HydraEngine`) `./scripts/verify.sh` ile **gerçekten** derlenip test edilir.
- iOS-bağımlı paketler (`HydraData/Health/Weather/Store/UI`) ve uygulama/widget/watch hedefleri yalnızca **iskelet** olarak durur; derleme + test tam Xcode'lu makinede yapılır.
- `swift test` swift-testing çerçevesini CLT `Developer/Frameworks` yolundan bulur; `verify.sh` bu yolu otomatik ekler.

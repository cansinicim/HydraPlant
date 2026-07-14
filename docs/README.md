# docs/

HydraPlant spesifikasyonu. Kaynak (source of truth) buradadır — özellikle motor ve
sağlık güvenliği için (docs/01 §6, §7). Android portu koddan değil bu dokümanlardan yazılır.

## Doküman haritası

| # | Dosya | İçerik |
|---|---|---|
| 00 | `00-README.md` | Yön bulma, roller, ritüeller, ilk gün kurulumu |
| 01 | `01-teknik-dokumantasyon.md` | Ürün, mimari, ADR, algoritma spec, fazlar, sprintler, riskler |
| 02 | `02-paket-arayuzleri.md` | 7 SPM paketinin public API sözleşmesi |
| 03 | `03-ekran-ve-akis-spesifikasyonu.md` | Her ekran, durum, navigasyon, kenar vaka |
| 04 | `04-tasarim-sistemi.md` | Renk/tipografi/boşluk token, bileşen, hareket, erişilebilirlik |
| 05 | `05-backlog.md` | Epik → hikâye → Gherkin kabul kriteri → puan |
| 06 | `06-muhendislik-standartlari.md` | Git, PR, kod incelemesi, DoR/DoD, CI, sürüm |
| 07 | `07-metin-katalogu.md` | Kullanıcıya görünen tüm metinler, lokalizasyon anahtarları |
| 08 | `08-claude-code-rehberi.md` | Claude Code kurulumu, hook, sprint prompt'ları |

## Not

Bu 9 doküman proje sahibinin sağladığı orijinal spesifikasyondur. `00-08` dosyalarını
bu klasöre olduğu gibi yerleştir. Kod ile doküman çelişirse:

- **§6 Motor ve §7 Sağlık güvenliği:** doküman doğrudur, kod düzeltilir.
- Diğer her yerde: kod doğrudur, doküman güncellenir.

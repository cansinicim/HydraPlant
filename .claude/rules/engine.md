---
paths: ["Packages/HydraEngine/**", "Packages/HydraCore/**"]
---

# HydraEngine kuralları

**`docs/01-teknik-dokumantasyon.md` §6 ve §7 bu paketin tek doğruluk kaynağıdır.**
Kod ile doküman çelişirse **doküman doğrudur, kod düzeltilir.** (Diğer paketlerde tersi geçerli.)
Sebep: Android portu (v1.2) koddan değil, bu dokümandan yazılacak.

## Zorunlu

- Saf: Foundation dışında hiçbir framework import edilmez. Hook ile engelleniyor.
- `Date()` doğrudan çağrılmaz — `init(now:)` ile enjekte edilir (deterministik test).
- Her katsayı bir `SPEC:` yorumu taşır ve doküman bölümünü referanslar:
  ```swift
  // SPEC: docs/01 §6.3 — 1.2 ml/kcal; ~1 L/saat ter ve ~600 kcal/saat aktif yakım varsayımı.
  let mlPerKcal = 1.2
  ```
- Güvenlik sabitleri `SAFETY-CRITICAL` yorumu taşır. Bunlara dokunma.

## Garantiler (her biri test edilmeli)

| Garanti | Test adı |
|---|---|
| `finalML ∈ 1600...6000` her girdide | `neverExceedsSafetyCeiling` (10k fuzz) |
| `hasMedicalCaution → finalML == 2000` | `medicalCautionForcesFixedGoal` |
| Sodyum üst sınırı ≤ 1500 mg | `sodiumNeverExceedsCeiling` |
| NaN / sonsuz girdi → taban değer, çökme yok | `handlesCorruptedInput` |
| Aynı girdi → aynı çıktı | `isDeterministic` |

## Yasak

- **Kafein cezasını iki kez uygulamak.** Hidrasyon faktörü *tüketim* tarafında,
  300 mg üstü ceza *hedef* tarafında. Bu ayrım bilinçlidir (docs/01 §6.4).
- `GoalReason` içinde lokalize metin üretmek. Motor `localizationKey` döner, metin değil.
- Rastgelelik, `Date()`, dosya okuma, ağ.

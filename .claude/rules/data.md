---
paths: ["Packages/HydraData/**"]
---

# HydraData kuralları

## CloudKit kısıtları (ihlali sessiz senkron bozulmasıdır)
- `@Attribute(.unique)` **kullanılamaz**
- Tüm özellikler varsayılan değerli veya `Optional`
- Tüm ilişkiler `Optional` + `inverse` tanımlı

## DTO sınırı
`@Model` sınıfları paket dışına **çıkmaz.** Public imzalar `Sendable` struct döner.

Sebep konfor değil doğruluktur: SwiftData nesneleri `ModelContext`'lerine bağlıdır.
Arka plan aktöründe oluşturulan bir nesneye `@MainActor` bir view'dan erişmek
tanımsız davranıştır. Bu sınırı bir kez delersen üretimde açıklanamayan çökmeler görürsün.

## Şema dondurma
S1 sonunda CloudKit şeması Production'a dağıtılır. Sonrasında **alan silinemez, tip değişemez.**
Yeni alan eklerken: varsayılan değerli olmalı.

## Gün sınırı
`DailyLog.date` = kaydın oluşturulduğu andaki **cihazın yerel** takvim gününün başlangıcı.
Sonradan değişmez. DST (23 ve 25 saatlik günler) ve saat dilimi değişimi testleri zorunlu.

## Çakışma çözümü
`HydrationEntry` **toplamsaldır** — dedupe yapma.
İki cihazdan aynı anda gelen iki kayıt, iki ayrı gerçek olaydır.
Sessizce veri silmek, çift kayıttan çok daha kötü bir hatadır.

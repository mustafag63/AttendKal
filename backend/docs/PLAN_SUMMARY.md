# AttendKal Abonelik Planları

## 📋 Basitleştirilmiş Plan Yapısı

Artık sadece **2 plan** bulunmaktadır:

### 🆓 **FREE Plan**
- **Fiyat:** Tamamen ücretsiz
- **Kurs Limiti:** Maksimum **2 kurs**
- **Özellikler:**
  - ✅ Temel yoklama takibi
  - ✅ Email desteği
  - ❌ Gelişmiş analitik yok
  - ❌ Rapor dışa aktarma yok

### 💎 **PREMIUM Plan** (Önerilen)
- **Fiyat:** $19.99/ay *(Beta döneminde ücretsiz)*
- **Kurs Limiti:** **Sınırsız kurs**
- **Özellikler:**
  - ✅ Sınırsız kurs
  - ✅ Gelişmiş analitik
  - ✅ Öncelikli destek
  - ✅ Rapor dışa aktarma
  - ✅ Özel entegrasyonlar

## 🔄 **Plan Değişimi**

- Kullanıcılar **FREE** ve **PREMIUM** arasında serbestçe geçiş yapabilir
- Şu anda **hiçbir ödeme gerekmiyor** (beta dönem)
- **Anında aktivasyon**

## 🚀 **API Endpoints**

```bash
# Planları görüntüle
GET /api/subscriptions/plans

# Mevcut planı görüntüle  
GET /api/subscriptions/

# Plan değiştir
POST /api/subscriptions/change-plan
Body: { "plan": "PREMIUM" }
```

## 📊 **Karşılaştırma**

| Özellik | FREE | PREMIUM |
|---------|------|---------|
| **Kurs Sayısı** | 2 | Sınırsız |
| **Analitik** | ❌ | ✅ |
| **Rapor Dışa Aktarma** | ❌ | ✅ |
| **Öncelikli Destek** | ❌ | ✅ |
| **Özel Entegrasyonlar** | ❌ | ✅ |
| **Fiyat** | Ücretsiz | Ücretsiz* |

**Beta döneminde ödeme sistemi aktif değil*

## 💡 **Tavsiye**

**PREMIUM planı** şu anda ücretsiz olduğu için herkese öneriyoruz! 🎉 
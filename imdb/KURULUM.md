# 🚀 FilMix Kurulum Rehberi

Bu rehber FilMix uygulamasını baştan sona kurmak için gerekli tüm adımları içerir.

## 📋 Ön Gereksinimler

### Sistem Gereksinimleri

- **Flutter SDK**: 3.0 veya üzeri
- **Python**: 3.8 veya üzeri
- **Git**: Versiyon kontrolü için
- **İnternet Bağlantısı**: Film verileri için

### Geliştirme Ortamı

- **Android Studio** veya **VS Code**
- **Flutter ve Dart eklentileri**
- **Python eklentileri** (VS Code için)

## 🔧 Adım Adım Kurulum

### 1️⃣ Proje Dosyalarını İndirin

```bash
git clone <repository-url>
cd imdb
```

### 2️⃣ TMDb API Anahtarı Alın

#### a) TMDb Hesabı Oluşturun

1. [themoviedb.org](https://www.themoviedb.org) adresine gidin
2. "Sign Up" ile hesap oluşturun
3. E-posta doğrulamasını yapın

#### b) API Anahtarı İsteyin

1. Hesabınıza giriş yapın
2. Profil menüsünden "Settings" → "API" seçin
3. "Request an API Key" butonuna tıklayın
4. "Developer" seçeneğini seçin
5. Gerekli bilgileri doldurun:
   - **Application Name**: FilMix
   - **Application URL**: http://localhost
   - **Application Summary**: Film keşif uygulaması
6. API anahtarınızı kopyalayın

#### c) API Anahtarını Yapılandırın

`lib/movie_service.dart` dosyasını açın ve şu satırı bulun:

```dart
defaultValue: 'BURAYA_TMDB_API_ANAHTARINIZI_YAZIN'
```

Bu kısmı kendi API anahtarınızla değiştirin:

```dart
defaultValue: 'abcd1234efgh5678...'  // Gerçek API anahtarınız
```

### 3️⃣ Backend Kurulumu

#### a) Python Bağımlılıklarını Yükleyin

```bash
cd backend
pip install -r requirements.txt
```

#### b) Backend'i Başlatın

```bash
python app.py
```

✅ Başarılı kurulum mesajı:

```
FilMix Backend başlatılıyor...
Veritabanı tabloları oluşturuldu!
* Running on http://127.0.0.1:5000
```

### 4️⃣ Flutter Uygulamasını Çalıştırın

#### a) Bağımlılıkları Yükleyin

```bash
cd ..  # Ana dizine dönün
flutter pub get
```

#### b) Uygulamayı Başlatın

**Web için:**

```bash
flutter run -d chrome
```

**Android için:**

```bash
flutter run -d <device-id>
```

**iOS için (Mac'te):**

```bash
flutter run -d ios
```

## ✅ Kurulum Doğrulama

### Backend Kontrolü

`http://localhost:5000` adresine browser'da gidin. Şu mesajı görmelisiniz:

```
Cannot GET /
```

Bu normal! Backend çalışıyor demektir.

### API Test

Backend loglarında şu endpoint'leri görmelisiniz:

- POST /register - Kullanıcı kaydı
- POST /login - Kullanıcı girişi
- GET /favorites - Favori filmler
- POST /ratings - Film puanlama

### Flutter Uygulaması Kontrolü

1. Uygulama açıldığında giriş/kayıt ekranı gelmelidir
2. Kayıt olun veya giriş yapın
3. Ana sayfada filmler yüklenmelidir
4. Arama çubuğu çalışmalıdır

## 🐛 Sık Karşılaşılan Sorunlar

### Problem: "API anahtarı geçerli değil" hatası

**Çözüm:**

1. API anahtarının doğru kopyalandığını kontrol edin
2. TMDb hesabınızın doğrulandığını kontrol edin
3. API anahtarının aktif olduğunu kontrol edin

### Problem: Backend bağlantı hatası

**Çözüm:**

1. Backend'in çalıştığını kontrol edin (`python app.py`)
2. Port 5000'in boş olduğunu kontrol edin
3. Firewall ayarlarını kontrol edin

### Problem: Flutter bağımlılık hatası

**Çözüm:**

```bash
flutter clean
flutter pub get
flutter run
```

### Problem: CORS hatası

**Çözüm:**
Backend'de CORS zaten aktif. Tarayıcı cache'ini temizleyin.

## 🔒 Güvenlik Önerileri

### Geliştirme Ortamı

- API anahtarını kod içinde saklayın (sadece geliştirme için)
- `.gitignore` dosyasının güncel olduğunu kontrol edin

### Production Ortamı

- Environment variables kullanın
- HTTPS kullanın
- API rate limitlerini ayarlayın
- Database şifreleyin

## 📞 Yardım

### Hata Alma Durumunda

1. **Console loglarını** kontrol edin
2. **Network sekmesini** kontrol edin (Developer Tools)
3. **Backend loglarını** kontrol edin

### İletişim

- GitHub Issues bölümünde sorun bildirin
- Detaylı hata mesajları ve logları paylaşın

## 🎉 Başarılı Kurulum!

Tüm adımları tamamladıysanız, FilMix uygulamanız çalışır durumda!

### Sonraki Adımlar

1. Hesap oluşturun
2. Film arayın ve keşfedin
3. Favorilere ekleyin
4. Puan verin
5. Profil bilgilerinizi güncelleyin

**İyi eğlenceler! 🍿🎬**

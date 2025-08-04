# 🎬 FilMix - Film Keşif Uygulaması

FilMix, kullanıcıların filmler keşfedebileceği, favorilerine ekleyebileceği ve puanlayabileceği modern bir mobil uygulamadır. Flutter ile geliştirilmiş olan bu uygulama, kullanıcı dostu arayüzü ve güçlü backend sistemi ile kapsamlı bir film deneyimi sunar.

## 🌟 Özellikler

### 🔐 Kullanıcı Yönetimi

- **Kayıt & Giriş**: Güvenli kullanıcı kaydı ve giriş sistemi
- **Profil Yönetimi**: Kullanıcı adı, e-posta ve şifre güncelleme
- **Profil Fotoğrafı**: Kameradan çekme veya galeriden seçme
- **JWT Authentication**: Güvenli token tabanlı kimlik doğrulama

### 🎭 Film Özellikleri

- **Film Keşfi**: Güncel ve popüler filmleri keşfetme
- **Arama**: Film başlığına göre gerçek zamanlı arama
- **Kategori Filtreleme**: Film türlerine göre filtreleme
- **Detaylı Bilgiler**: Film posteri, açıklama, yıl bilgisi

### ❤️ Kişiselleştirme

- **Favoriler**: Filmleri favorilere ekleme/çıkarma
- **Puan Verme**: 5 yıldızlı puan sistemi
- **Favoriler Sayfası**: Tüm favori filmleri tek sayfada görme
- **Kişisel Puanlar**: Verdiğiniz puanları takip etme

### 🎨 Kullanıcı Arayüzü

- **Modern Tasarım**: Material Design prensiplerine uygun
- **Bottom Navigation**: Ana sayfa, Favoriler, Profil arası kolay geçiş
- **Responsive**: Tüm ekran boyutlarına uyumlu
- **Animasyonlar**: Akıcı geçiş efektleri

## 🛠️ Teknoloji Stack

### Frontend (Flutter)

- **Framework**: Flutter 3.0+
- **Dil**: Dart
- **State Management**: StatefulWidget
- **HTTP İstekleri**: http paket
- **UI Bileşenleri**: Material Design

### Backend (Python)

- **Framework**: Flask
- **Veritabanı**: SQLite
- **ORM**: SQLAlchemy
- **Authentication**: JWT (JSON Web Tokens)
- **File Upload**: Werkzeug
- **CORS**: Flask-CORS

### Harici API

- **Film Verileri**: The Movie Database (TMDb) API
- **Görüntüler**: TMDb Image API

## 📁 Proje Yapısı

```
imdb/
├── lib/                          # Flutter kaynak kodu
│   ├── main.dart                 # Ana uygulama dosyası
│   ├── auth_service.dart         # Kimlik doğrulama servisi
│   ├── movie_service.dart        # Film API servisi
│   ├── login_register_page.dart  # Giriş/Kayıt sayfası
│   ├── movie.dart                # Ana film sayfası
│   ├── favorites_page.dart       # Favoriler sayfası
│   ├── profile_page.dart         # Profil sayfası
│   ├── star_rating_widget.dart   # Yıldız puanlama widget'ı
│   └── movie_model.dart          # Film veri modeli
├── backend/                      # Python Flask backend
│   ├── app.py                    # Ana backend dosyası
│   ├── requirements.txt          # Python bağımlılıkları
│   ├── README.md                 # Backend kurulum rehberi
│   ├── SETUP.md                  # Detaylı kurulum kılavuzu
│   └── instance/                 # Veritabanı dosyaları
├── assets/                       # Görseller ve kaynaklar
│   └── images/
└── android/ios/web/windows/      # Platform-specific dosyalar
```

## 🚀 Kurulum

### Ön Gereksinimler

- Flutter SDK (3.0+)
- Python 3.8+
- Android Studio / VS Code
- Git

### 1. Projeyi Klonlayın

```bash
git clone <repository-url>
cd imdb
```

### 2. Backend Kurulumu

```bash
cd backend
pip install -r requirements.txt
python app.py
```

Backend şu adreste çalışmaya başlayacak: `http://localhost:5000`

### 3. Flutter Kurulumu

```bash
flutter pub get
flutter run
```

## 🔧 Yapılandırma

### TMDb API Anahtarı Kurulumu

Bu uygulama film verilerini [The Movie Database (TMDb)](https://www.themoviedb.org/) API'sinden alır. Uygulamayı çalıştırabilmek için kendi API anahtarınızı almanız gerekmektedir.

#### 1. TMDb API Anahtarı Alma

1. [TMDb](https://www.themoviedb.org) hesabı oluşturun
2. [API Settings](https://www.themoviedb.org/settings/api) sayfasına gidin
3. "Request an API Key" bölümünden API anahtarınızı alın

#### 2. API Anahtarını Yapılandırma

**Yöntem 1: Environment Variable (Önerilen)**

```bash
flutter run --dart-define=TMDB_API_KEY=your_actual_api_key_here
```

**Yöntem 2: Doğrudan Kod İçinde**
`lib/movie_service.dart` dosyasında:

```dart
static const String _apiKey = String.fromEnvironment(
  'TMDB_API_KEY',
  defaultValue: 'your_actual_api_key_here'  // Buraya API anahtarınızı yazın
);
```

#### 3. Güvenlik Notları

- ⚠️ API anahtarınızı asla public repository'lerde paylaşmayın
- 🔒 Gerçek projeler için environment variables kullanın
- 📝 `API_CONFIG.md` dosyasında detaylı talimatlar bulunmaktadır

### Backend Yapılandırması

Backend ayarları `backend/app.py` dosyasında yapılandırılabilir:

- Database URI
- Secret Key
- Upload dizinleri
- CORS ayarları

## 📱 Kullanım

### 1. Hesap Oluşturma

- Uygulamayı açın
- "Kayıt Ol" sekmesini seçin
- Kullanıcı adı, e-posta ve şifre bilgilerinizi girin

### 2. Film Keşfi

- Ana sayfada güncel filmleri görebilirsiniz
- Arama çubuğunu kullanarak film arayın
- Filtre ikonuna tıklayarak kategorilere göre filtreleyin

### 3. Favoriler & Puanlama

- Film kartlarındaki kalp ikonuna tıklayarak favorilere ekleyin
- Yıldız ikonlarına tıklayarak puan verin
- "Favoriler" sekmesinden tüm favori filmlerinizi görün

### 4. Profil Yönetimi

- "Profil" sekmesinden hesap bilgilerinizi güncelleyin
- Profil fotoğrafınızı değiştirin
- Şifrenizi güncelleyin

## 🔐 Güvenlik

- **Şifre Hashleme**: Werkzeug ile güvenli şifre hashleme
- **JWT Tokens**: Güvenli oturum yönetimi
- **Input Validation**: Tüm kullanıcı girdileri doğrulanır
- **File Upload Security**: Güvenli dosya yükleme
- **CORS Protection**: Cross-origin istekleri korunması

## 🐛 Bilinen Sorunlar

- Web versiyonunda kamera erişimi sınırlı
- Büyük dosya yüklemelerinde zaman aşımı olabilir
- İnternet bağlantısı olmadan film verileri yüklenemez




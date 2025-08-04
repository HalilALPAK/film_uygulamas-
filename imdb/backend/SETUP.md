# FilMix Backend - Çalıştırma Talimatları

## 1. Backend Kurulumu

### Python Virtual Environment Oluşturma:

```bash
cd backend
python -m venv venv
```

### Virtual Environment Aktifleştirme:

**Windows:**

```bash
venv\Scripts\activate
```

**Mac/Linux:**

```bash
source venv/bin/activate
```

### Bağımlılıkları Yükleme:

```bash
pip install -r requirements.txt
```

## 2. Backend Başlatma

```bash
python app.py
```

Backend `http://localhost:5000` adresinde çalışacak.

## 3. API Test Etme

### Test scripti ile:

```bash
python test_api.py
```

### Manuel test (curl ile):

**Kullanıcı Kaydı:**

```bash
curl -X POST http://localhost:5000/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"123456"}'
```

**Giriş:**

```bash
curl -X POST http://localhost:5000/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"123456"}'
```

## 4. Özellikler

✅ **Kullanıcı Kaydı ve Girişi**

- Username, email, şifre ile kayıt
- JWT token tabanlı giriş

✅ **Profil Yönetimi**

- Profil bilgileri görüntüleme
- Kullanıcı adı ve email güncelleme
- Şifre değiştirme

✅ **Profil Fotoğrafı**

- Dosya yükleme (PNG, JPG, JPEG, GIF)
- Fotoğraf değiştirme
- Varsayılan fotoğrafa dönüş

✅ **Güvenlik**

- Şifre hash'leme
- JWT token koruması
- Dosya güvenlik kontrolleri

## 5. Veritabanı

SQLite veritabanı otomatik olarak oluşturulur (`filmix.db`).

## 6. Dosya Yapısı

```
backend/
├── app.py                 # Ana Flask uygulaması
├── requirements.txt       # Python bağımlılıkları
├── test_api.py           # API test scripti
├── README.md             # Dokümantasyon
├── SETUP.md              # Bu dosya
├── filmix.db             # SQLite veritabanı (otomatik)
└── uploads/
    └── profile_photos/   # Profil fotoğrafları (otomatik)
```

## 7. Frontend Entegrasyonu

Backend hazır! Artık Flutter uygulamanızdan bu API'leri kullanabilirsiniz:

- `POST /register` - Kayıt
- `POST /login` - Giriş
- `GET /profile` - Profil
- `PUT /profile` - Profil güncelle
- `POST /upload_photo` - Fotoğraf yükle
- `POST /change_password` - Şifre değiştir

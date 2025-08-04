# FilMix Backend API

Flask tabanlı FilMix uygulaması için backend API.

## Özellikler

- ✅ Kullanıcı kaydı ve girişi
- ✅ JWT token tabanlı kimlik doğrulama
- ✅ Profil bilgileri yönetimi
- ✅ Şifre değiştirme
- ✅ Profil fotoğrafı yükleme ve yönetimi
- ✅ SQLite veritabanı
- ✅ CORS desteği

## Kurulum

1. **Sanal ortam oluştur:**

```bash
python -m venv venv
venv\Scripts\activate  # Windows
# veya
source venv/bin/activate  # Linux/Mac
```

2. **Bağımlılıkları yükle:**

```bash
pip install -r requirements.txt
```

3. **Uygulamayı başlat:**

```bash
python app.py
```

Server `http://localhost:5000` adresinde çalışacak.

## API Endpoints

### 1. Kullanıcı Kaydı

- **POST** `/register`
- **Body:**

```json
{
  "username": "kullanici_adi",
  "email": "email@example.com",
  "password": "sifre123"
}
```

### 2. Kullanıcı Girişi

- **POST** `/login`
- **Body:**

```json
{
  "username": "kullanici_adi",
  "password": "sifre123"
}
```

### 3. Profil Bilgileri

- **GET** `/profile`
- **Headers:** `Authorization: Bearer <token>`

### 4. Profil Güncelleme

- **PUT** `/profile`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**

```json
{
  "username": "yeni_kullanici_adi",
  "email": "yeni_email@example.com"
}
```

### 5. Şifre Değiştirme

- **POST** `/change_password`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**

```json
{
  "current_password": "eski_sifre",
  "new_password": "yeni_sifre"
}
```

### 6. Profil Fotoğrafı Yükleme

- **POST** `/upload_photo`
- **Headers:** `Authorization: Bearer <token>`
- **Body:** `multipart/form-data` ile dosya

### 7. Profil Fotoğrafını Sıfırla

- **POST** `/reset_photo`
- **Headers:** `Authorization: Bearer <token>`

### 8. Profil Fotoğrafını Görüntüle

- **GET** `/profile_photos/<filename>`

## Dosya Yapısı

```
backend/
├── app.py              # Ana uygulama dosyası
├── requirements.txt    # Python bağımlılıkları
├── README.md          # Bu dosya
├── filmix.db          # SQLite veritabanı (otomatik oluşur)
└── uploads/
    └── profile_photos/ # Profil fotoğrafları (otomatik oluşur)
```

## Güvenlik

- Şifreler hash'lenerek saklanır
- JWT token ile kimlik doğrulama
- Dosya yükleme güvenlik kontrolleri
- CORS koruması

## Test

API'yi test etmek için Postman veya curl kullanabilirsiniz:

```bash
# Kullanıcı kaydı
curl -X POST http://localhost:5000/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"123456"}'

# Giriş
curl -X POST http://localhost:5000/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"123456"}'
```

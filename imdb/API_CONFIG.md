# API Anahtarları Yapılandırma Dosyası

## TMDb API Anahtarı

Bu dosya API anahtarlarını saklamak için oluşturulmuştur. Güvenlik nedeniyle gerçek API anahtarları bu dosyada saklanmaz.

### TMDb API Anahtarı Alma

1. [TMDb](https://www.themoviedb.org) hesabı oluşturun
2. [API Settings](https://www.themoviedb.org/settings/api) sayfasına gidin
3. API anahtarınızı kopyalayın
4. `lib/movie_service.dart` dosyasında `BURAYA_TMDB_API_ANAHTARINIZI_YAZIN` kısmına yapıştırın

### Örnek API Anahtarı Formatı

```
12345abc67890def12345abc67890def
```

### Güvenlik Notları

- API anahtarınızı asla public repository'lerde paylaşmayın
- `.gitignore` dosyasına API anahtarı içeren dosyaları ekleyin
- Production'da environment variables kullanın

### Environment Variables (İsteğe bağlı)

Daha güvenli kullanım için environment variables kullanabilirsiniz:

```bash
export TMDB_API_KEY="your_api_key_here"
```

Sonra kodda:

```dart
static const String _apiKey = String.fromEnvironment('TMDB_API_KEY', defaultValue: 'BURAYA_TMDB_API_ANAHTARINIZI_YAZIN');
```

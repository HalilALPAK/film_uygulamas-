import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://localhost:5000';
  static String? _token;
  static Map<String, dynamic>? _user;

  // Get current token
  static String? get token => _token;

  // Get current user
  static Map<String, dynamic>? get user => _user;

  // Check if user is logged in
  static bool get isLoggedIn => _token != null;

  // Login
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username.trim(), 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _user = data['user'];
        return {'success': true, 'message': 'Giriş başarılı!', 'user': _user};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Giriş başarısız!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Register
  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Kayıt başarılı! Şimdi giriş yapabilirsiniz.',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Kayıt başarısız!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Get profile
  static Future<Map<String, dynamic>> getProfile() async {
    if (_token == null) {
      return {'success': false, 'message': 'Token bulunamadı!'};
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _user = data['user'];
        return {'success': true, 'user': _user};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Profil alınamadı!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile(
    String username,
    String email,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'Token bulunamadı!'};
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'username': username.trim(), 'email': email.trim()}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _user = data['user'];
        return {
          'success': true,
          'message': 'Profil güncellendi!',
          'user': _user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Profil güncellenemedi!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'Token bulunamadı!'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/change_password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Şifre değiştirildi!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Şifre değiştirilemedi!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Upload profile photo
  static Future<Map<String, dynamic>> uploadProfilePhoto(
    String filePath,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'Token bulunamadı!'};
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload_photo'),
      );
      request.headers['Authorization'] = 'Bearer $_token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (response.statusCode == 200) {
        _user = data['user'];
        return {
          'success': true,
          'message': 'Profil fotoğrafı güncellendi!',
          'user': _user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Fotoğraf yüklenemedi!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Reset profile photo
  static Future<Map<String, dynamic>> resetProfilePhoto() async {
    if (_token == null) {
      return {'success': false, 'message': 'Token bulunamadı!'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset_photo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _user = data['user'];
        return {
          'success': true,
          'message': 'Profil fotoğrafı sıfırlandı!',
          'user': _user,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Fotoğraf sıfırlanamadı!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Logout
  static void logout() {
    _token = null;
    _user = null;
  }

  // Get profile photo URL
  static String getProfilePhotoUrl(String? filename) {
    if (filename == null || filename == 'default.png') {
      return '';
    }
    return '$_baseUrl/profile_photos/$filename';
  }

  // ==================== FAVORİLER ====================

  // Favorilere film ekleme
  static Future<Map<String, dynamic>> addToFavorites(
    String movieId,
    String movieTitle,
    String? moviePoster,
    String? movieYear,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'Giriş yapılmamış!'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'movie_id': movieId,
          'movie_title': movieTitle,
          'movie_poster': moviePoster ?? '',
          'movie_year': movieYear ?? '',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'favorite': data['favorite'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Favorilere eklenemedi!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Favorilerden film çıkarma
  static Future<Map<String, dynamic>> removeFromFavorites(
    String movieId,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'Giriş yapılmamış!'};
    }

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/favorites/$movieId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Favorilerden çıkarılamadı!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Favori filmleri listeleme
  static Future<Map<String, dynamic>> getFavorites() async {
    if (_token == null) {
      return {'success': false, 'message': 'Giriş yapılmamış!'};
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'favorites': data['favorites'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Favoriler alınamadı!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Film favoride mi kontrol
  static Future<bool> isFavorite(String movieId) async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/favorites/check/$movieId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_favorite'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== PUANLAMA ====================

  // Film puanlama
  static Future<Map<String, dynamic>> rateMovie(
    String movieId,
    double rating,
    String movieTitle,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'Giriş yapılmamış!'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ratings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'movie_id': movieId,
          'rating': rating,
          'movie_title': movieTitle,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'rating': data['rating'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Film puanlanamadı!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Film puanını alma
  static Future<double?> getMovieRating(String movieId) async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ratings/$movieId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rating'] != null) {
          return data['rating']['rating']?.toDouble();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Kullanıcının tüm puanları
  static Future<Map<String, dynamic>> getUserRatings() async {
    if (_token == null) {
      return {'success': false, 'message': 'Giriş yapılmamış!'};
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ratings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'ratings': data['ratings'],
          'count': data['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Puanlar alınamadı!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Film puanını silme
  static Future<Map<String, dynamic>> deleteRating(String movieId) async {
    if (_token == null) {
      return {'success': false, 'message': 'Giriş yapılmamış!'};
    }

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/ratings/$movieId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Puan silinemedi!',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';

class MovieService {
  // API anahtarını environment variable'dan al, yoksa default değer kullan
  // Kullanım: flutter run --dart-define=TMDB_API_KEY=your_api_key
  static const String _apiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: 'BURAYA_TMDB_API_ANAHTARINIZI_YAZIN',
  );
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // API anahtarının geçerli olup olmadığını kontrol et
  static bool get isApiKeyValid =>
      _apiKey != 'BURAYA_TMDB_API_ANAHTARINIZI_YAZIN' && _apiKey.isNotEmpty;

  Future<List<Movie>> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/movie/popular?api_key=$_apiKey&language=tr-TR&page=1',
      ),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      return results.map((m) => Movie.fromJson(m)).toList();
    } else {
      throw Exception('Film verisi alınamadı');
    }
  }

  Future<List<Movie>> fetchNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/movie/now_playing?api_key=$_apiKey&language=tr-TR&page=1',
      ),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      return results.map((m) => Movie.fromJson(m)).toList();
    } else {
      throw Exception('Gündemdeki filmler alınamadı');
    }
  }

  Future<List<Movie>> fetchRandomMovies(int count) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/movie/popular?api_key=$_apiKey&language=tr-TR&page=1',
      ),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      results.shuffle();
      return results.take(count).map((m) => Movie.fromJson(m)).toList();
    } else {
      throw Exception('Rastgele filmler alınamadı');
    }
  }

  Future<Map<String, dynamic>> fetchGenres() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=tr-TR'),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json;
    } else {
      throw Exception('Kategoriler alınamadı');
    }
  }

  Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/discover/movie?api_key=$_apiKey&language=tr-TR&with_genres=$genreId&page=1',
      ),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      return results.map((m) => Movie.fromJson(m)).toList();
    } else {
      throw Exception('Kategori filmleri alınamadı');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';

class MovieService {
  static const String _apiKey = '91710ea852c680a9d71587db321fa761';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

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
}

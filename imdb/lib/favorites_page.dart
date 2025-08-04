import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'star_rating_widget.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favorites = [];
  Map<String, double> _ratings = {};
  bool _isLoading = true;
  bool _isLoadingRatings = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.getFavorites();

    if (result['success']) {
      setState(() {
        _favorites = List<Map<String, dynamic>>.from(result['favorites']);
      });

      // Load ratings for each favorite movie
      await _loadRatings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoadingRatings = true;
    });

    for (var favorite in _favorites) {
      final rating = await AuthService.getMovieRating(favorite['movie_id']);
      if (rating != null) {
        _ratings[favorite['movie_id']] = rating;
      }
    }

    setState(() {
      _isLoadingRatings = false;
    });
  }

  Future<void> _onRatingChanged(
    String movieId,
    String movieTitle,
    double rating,
  ) async {
    final result = await AuthService.rateMovie(movieId, rating, movieTitle);

    if (result['success']) {
      setState(() {
        _ratings[movieId] = rating;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  void _onFavoriteChanged(String movieId, bool isFavorite) {
    if (!isFavorite) {
      // Film favorilerden çıkarıldı, listeden kaldır
      setState(() {
        _favorites.removeWhere((fav) => fav['movie_id'] == movieId);
        _ratings.remove(movieId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favori Filmlerim'),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadFavorites),
        ],
      ),
      body: Container(
        color: Colors.blueGrey.shade900,
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Favoriler yükleniyor...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
                : _favorites.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Henüz favori filminiz yok',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Film sayfasından kalp ikonuna tıklayarak\nfavorilerinize ekleyebilirsiniz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = _favorites[index];
                    final movieId = favorite['movie_id'];
                    final currentRating = _ratings[movieId] ?? 0.0;

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Film posteri
                            Container(
                              width: 80,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade300,
                              ),
                              child:
                                  favorite['movie_poster'] != null &&
                                          favorite['movie_poster'].isNotEmpty
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          favorite['movie_poster'],
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Center(
                                              child: Icon(
                                                Icons.movie,
                                                color: Colors.grey.shade600,
                                                size: 40,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      : Center(
                                        child: Icon(
                                          Icons.movie,
                                          color: Colors.grey.shade600,
                                          size: 40,
                                        ),
                                      ),
                            ),
                            SizedBox(width: 12),
                            // Film bilgileri
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    favorite['movie_title'] ??
                                        'Bilinmeyen Film',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  if (favorite['movie_year'] != null &&
                                      favorite['movie_year'].isNotEmpty)
                                    Text(
                                      'Yıl: ${favorite['movie_year']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Eklenme: ${_formatDate(favorite['added_at'])}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  // Puan verme
                                  Row(
                                    children: [
                                      Text(
                                        'Puanım: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      _isLoadingRatings
                                          ? SizedBox(
                                            width: 100,
                                            height: 20,
                                            child: LinearProgressIndicator(
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.amber,
                                                  ),
                                            ),
                                          )
                                          : StarRating(
                                            rating: currentRating,
                                            size: 20,
                                            onRatingChanged: (rating) {
                                              _onRatingChanged(
                                                movieId,
                                                favorite['movie_title'] ??
                                                    'Bilinmeyen Film',
                                                rating,
                                              );
                                            },
                                          ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Favori butonu
                            FavoriteButton(
                              movieId: movieId,
                              movieTitle:
                                  favorite['movie_title'] ?? 'Bilinmeyen Film',
                              moviePoster: favorite['movie_poster'],
                              movieYear: favorite['movie_year'],
                              initialIsFavorite: true,
                              onFavoriteChanged: (isFavorite) {
                                _onFavoriteChanged(movieId, isFavorite);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Bilinmiyor';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Bilinmiyor';
    }
  }
}

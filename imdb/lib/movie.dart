import 'package:flutter/material.dart';
import 'movie_model.dart' as model;
import 'movie_service.dart';
import 'profile_page.dart';
import 'auth_service.dart';
import 'star_rating_widget.dart';

List<model.Movie> searchResults = [];
String searchQuery = "";

class Movie extends StatefulWidget {
  const Movie({super.key});

  @override
  State<Movie> createState() => _MovieState();
}

class _MovieState extends State<Movie> with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  final PageController _pageController = PageController(
    viewportFraction: 1 / 2,
  );
  // final PageController _favController = PageController(viewportFraction: 1 / 2); // Removed unused controller
  int _currentPage = 0;

  List<model.Movie> nowPlayingMovies = [];
  List<model.Movie> randomMovies = [];
  List<Map<String, dynamic>> genres = [];
  bool isLoading = true;

  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  bool isUserTyping = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.2, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    // API anahtarının geçerli olup olmadığını kontrol et
    if (!MovieService.isApiKeyValid) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'TMDb API anahtarı geçerli değil. Lütfen API_CONFIG.md dosyasını kontrol edin.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });
    final nowPlaying = await _movieService.fetchNowPlayingMovies();
    final randoms = await _movieService.fetchRandomMovies(10);
    final genresData = await _movieService.fetchGenres();
    setState(() {
      nowPlayingMovies = nowPlaying;
      randomMovies = randoms;
      genres = List<Map<String, dynamic>>.from(genresData['genres']);
      isLoading = false;
    });
  }

  Future<void> _refreshRandomMovies() async {
    final randoms = await _movieService.fetchRandomMovies(10);
    setState(() {
      randomMovies = randoms;
    });
  }

  void _showGenreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Film Kategorileri'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return ListTile(
                  title: Text(genre['name']),
                  onTap: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      final filteredMovies = await _movieService
                          .fetchMoviesByGenre(genre['id']);
                      setState(() {
                        nowPlayingMovies = filteredMovies;
                        isLoading = false;
                      });
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Filmler yüklenirken hata oluştu'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchMovies(); // Tüm filmleri yeniden yükle
              },
              child: Text('Tümünü Göster'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      searchQuery = value;
      if (value.isNotEmpty) {
        isUserTyping = true;
        _animationController.stop();
        searchResults =
            nowPlayingMovies
                .where(
                  (movie) =>
                      movie.title.toLowerCase().contains(value.toLowerCase()),
                )
                .toList();
      } else {
        isUserTyping = false;
        _animationController.repeat(reverse: true);
        searchResults = [];
      }
    });
  }

  void _goNext() {
    if (_currentPage + 2 < nowPlayingMovies.length) {
      _currentPage += 2;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (_currentPage - 2 >= 0) {
      _currentPage -= 2;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("FilMix"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),

      body: Container(
        color: Colors.blueGrey.shade900,
        padding: const EdgeInsets.all(16),
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Gündemdekiler",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    // Kartlar (now playing)
                    SizedBox(
                      height: h / 4,
                      child: Row(
                        children: [
                          // Geri Butonu
                          SizedBox(
                            width: 28,
                            height: h / 6,
                            child: ElevatedButton(
                              onPressed: _goBack,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              child: const Icon(Icons.arrow_back, size: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // PageView
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: nowPlayingMovies.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final model.Movie movie =
                                    nowPlayingMovies[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                          child: Image.network(
                                            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                            width: double.infinity,
                                            height: h / 6,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(Icons.broken_image),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          movie.title,
                                          style: TextStyle(fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // İleri Butonu
                          SizedBox(
                            width: 28,
                            height: h / 6,
                            child: ElevatedButton(
                              onPressed: _goNext,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              child: const Icon(Icons.arrow_forward, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Arama Çubuğu
                    SizedBox(
                      height: h / 12,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Film ara...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefix: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 8),
                              SlideTransition(
                                position: _offsetAnimation,
                                child: Image.asset(
                                  'assets/images/film_logo.png',
                                  width: 72,
                                  height: 72,
                                ),
                              ),
                            ],
                          ),
                          // 🔽 Sağ köşeye filtre ikonu eklendi
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.filter_alt_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              _showGenreDialog();
                            },
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        onChanged: _onChanged,
                      ),
                    ),
                    // Arama Sonuçları
                    if (searchQuery.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            "Arama Sonuçları",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          ...searchResults.map(
                            (movie) => Card(
                              child: ListTile(
                                leading: Image.network(
                                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Icon(Icons.broken_image),
                                ),
                                title: Text(
                                  movie.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  movie.overview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),
                    const Text(
                      "Favorilerin",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),

                    // Favoriler
                    // Favorilerin - yatay scroll ve 10 film
                    SizedBox(
                      height: h / 3.5,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(10, (i) {
                            if (randomMovies.length > i) {
                              final model.Movie movie = randomMovies[i];
                              return Container(
                                width: 160,
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                          width: double.infinity,
                                          height: h / 5,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(Icons.broken_image),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        movie.title,
                                        style: TextStyle(fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                width: 160,
                                margin: EdgeInsets.symmetric(horizontal: 8),
                              );
                            }
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Öneriler",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),

                    // Öneriler - yatay scroll ve 10 film
                    SizedBox(
                      height: h / 3.5,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(10, (i) {
                            if (randomMovies.length > i) {
                              final model.Movie movie = randomMovies[i];
                              return Container(
                                width: 160,
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                          width: double.infinity,
                                          height: h / 5,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(Icons.broken_image),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        movie.title,
                                        style: TextStyle(fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                width: 160,
                                margin: EdgeInsets.symmetric(horizontal: 8),
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Sadece en son iki random film ve Karıştır butonu
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/neo.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: SizedBox(
                          width: 300,
                          height: 200,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(2, (i) {
                                  if (randomMovies.length > i) {
                                    final model.Movie movie = randomMovies[i];
                                    return Card(
                                      color: i == 0 ? Colors.red : Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                              width: 80,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(Icons.broken_image),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              movie.title,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return SizedBox(width: 100, height: 100);
                                  }
                                }),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  // Sadece randomMovies güncellensin, sayfa yenilenmesin
                                  await _refreshRandomMovies();
                                },
                                child: Text("Karıştır"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

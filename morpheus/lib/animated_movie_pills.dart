import 'dart:math';
import 'package:flutter/material.dart';
import 'movie_service.dart';
import 'movie_model.dart';

class ToggleMoviePills extends StatefulWidget {
  const ToggleMoviePills({super.key});

  @override
  State<ToggleMoviePills> createState() => _ToggleMoviePillsState();
}

class _ToggleMoviePillsState extends State<ToggleMoviePills>
    with TickerProviderStateMixin {
  bool isRedExpanded = false;
  bool isBlueExpanded = false;
  Movie? redMovie;
  Movie? blueMovie;
  final movieService = MovieService();

  late AnimationController redShakeController;
  late AnimationController blueShakeController;
  late Animation<Offset> redOffsetAnimation;
  late Animation<Offset> blueOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _loadRandomMovies();

    redShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    blueShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    redOffsetAnimation = Tween<Offset>(
      begin: const Offset(-0.01, 0),
      end: const Offset(0.01, 0),
    ).animate(
      CurvedAnimation(parent: redShakeController, curve: Curves.easeInOut),
    );

    blueOffsetAnimation = Tween<Offset>(
      begin: const Offset(0.01, 0),
      end: const Offset(-0.01, 0),
    ).animate(
      CurvedAnimation(parent: blueShakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    redShakeController.dispose();
    blueShakeController.dispose();
    super.dispose();
  }

  Future<void> _loadRandomMovies() async {
    final movies = await movieService.fetchRandomMovies(2);
    setState(() {
      redMovie = movies[0];
      blueMovie = movies[1];
    });
  }

  Widget _buildPill({
    required bool isExpanded,
    required VoidCallback onTap,
    required Color color,
    required Movie? movie,
    required Animation<Offset> shakeAnimation,
  }) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          if (color == Colors.red) {
            isRedExpanded = !isRedExpanded;
          } else {
            isBlueExpanded = !isBlueExpanded;
          }
        });

        if (!isExpanded) {
          final randomMovies = await movieService.fetchRandomMovies(1);
          setState(() {
            if (color == Colors.red) {
              redMovie = randomMovies.first;
            } else {
              blueMovie = randomMovies.first;
            }
          });
        }
      },
      child: SlideTransition(
        position: shakeAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: isExpanded ? 160 : 120,
          height: isExpanded ? 190 : 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isExpanded ? 16 : 100),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              isExpanded && movie != null
                  ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan görseli
          Positioned.fill(
            child: Image.asset("assets/images/neo.png", fit: BoxFit.fill),
          ),

          // Kırmızı hap (sol alt)
          Positioned(
            left: 32,
            bottom: 90,
            child: _buildPill(
              isExpanded: isRedExpanded,
              onTap: () {},
              color: Colors.red,
              movie: redMovie,
              shakeAnimation: redOffsetAnimation,
            ),
          ),

          // Mavi hap (sağ alt)
          Positioned(
            right: 32,
            bottom: 90,
            child: _buildPill(
              isExpanded: isBlueExpanded,
              onTap: () {},
              color: Colors.blue,
              movie: blueMovie,
              shakeAnimation: blueOffsetAnimation,
            ),
          ),
        ],
      ),
    );
  }
}

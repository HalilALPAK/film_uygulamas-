import 'package:flutter/material.dart';
import 'auth_service.dart';

class StarRating extends StatefulWidget {
  final double rating;
  final Function(double) onRatingChanged;
  final bool isReadOnly;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    Key? key,
    required this.rating,
    required this.onRatingChanged,
    this.isReadOnly = false,
    this.size = 24.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap:
              widget.isReadOnly
                  ? null
                  : () {
                    setState(() {
                      _currentRating = index + 1.0;
                    });
                    widget.onRatingChanged(_currentRating);
                  },
          child: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color:
                index < _currentRating
                    ? widget.activeColor
                    : widget.inactiveColor,
            size: widget.size,
          ),
        );
      }),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final String movieId;
  final String movieTitle;
  final String? moviePoster;
  final String? movieYear;
  final bool initialIsFavorite;
  final Function(bool)? onFavoriteChanged;

  const FavoriteButton({
    Key? key,
    required this.movieId,
    required this.movieTitle,
    this.moviePoster,
    this.movieYear,
    this.initialIsFavorite = false,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    try {
      final result =
          _isFavorite
              ? await AuthService.removeFromFavorites(widget.movieId)
              : await AuthService.addToFavorites(
                widget.movieId,
                widget.movieTitle,
                widget.moviePoster,
                widget.movieYear,
              );

      if (result['success']) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        widget.onFavoriteChanged?.call(_isFavorite);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child:
              _isLoading
                  ? Container(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  )
                  : IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
        );
      },
    );
  }
}

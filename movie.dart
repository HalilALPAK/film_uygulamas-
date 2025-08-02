import 'package:flutter/material.dart';

class Movie extends StatefulWidget {
  const Movie({super.key});

  @override
  State<Movie> createState() => _MovieState();
}

class _MovieState extends State<Movie> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(
    viewportFraction: 1 / 2,
  );
  final PageController _favController = PageController(viewportFraction: 1 / 2);
  int _currentPage = 0;

  final List<String> images = List.generate(
    20,
    (index) => 'https://picsum.photos/200/300?random=$index',
  );

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.isNotEmpty && !isUserTyping) {
      setState(() {
        isUserTyping = true;
      });
      _animationController.stop();
    } else if (value.isEmpty && isUserTyping) {
      setState(() {
        isUserTyping = false;
      });
      _animationController.repeat(reverse: true);
    }
  }

  void _goNext() {
    if (_currentPage + 2 < images.length) {
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
      appBar: AppBar(title: const Text("Filmler")),
      body: Container(
        color: Colors.blueGrey.shade900,
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Gündemdekiler",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),

            // Kartlar
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
                      itemCount: images.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    images[index],
                                    width: double.infinity,
                                    height: h / 6,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Film",
                                  style: TextStyle(fontSize: 14),
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
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: _onChanged,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Favorilerin",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),

            // Favoriler
            SizedBox(
              height: h / 3.5,
              child: PageView.builder(
                controller: _favController,
                itemCount: images.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              images[index],
                              width: double.infinity,
                              height: h / 5,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text("Film", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Öneriler",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),

            // Öneriler
            SizedBox(
              height: h / 3.5,
              child: PageView.builder(
                controller: _favController,
                itemCount: images.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              images[index],
                              width: double.infinity,
                              height: h / 5,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text("Film", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Card(
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://picsum.photos/seed/card1/100/100',
                                    width: 80,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Kırmızı Kart",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://picsum.photos/seed/card2/100/100',
                                    width: 80,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Mavi Kart",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(onPressed: () {}, child: Text("Karıştır")),
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

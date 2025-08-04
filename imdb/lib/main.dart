import 'package:flutter/material.dart';
import 'login_register_page.dart';
import 'movie.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'auth_service.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = AuthService.isLoggedIn;
  }

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _onLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? MainPage(onLogout: _onLogout)
        : LoginRegisterPage(onLoginSuccess: _onLoginSuccess);
  }
}

class MainPage extends StatefulWidget {
  final VoidCallback? onLogout;

  const MainPage({super.key, this.onLogout});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const Movie(),
      const FavoritesPage(),
      ProfilePage(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.blueGrey.shade800,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Filmler'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

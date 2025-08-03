import 'package:flutter/material.dart';
import 'animated_movie_pills.dart'; // oluşturduğumuz dosya adı

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film Kartları',
      theme: ThemeData.dark(),
      home: const ToggleMoviePills(),
      debugShowCheckedModeBanner: false,
    );
  }
}

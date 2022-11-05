import 'package:flutter/material.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'home_screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({Key? key}) : super(key: key);

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: const Home(),
      duration: 3000,
      imageSize: 200,
      imageSrc: "assets/G.png",
      backgroundColor: const Color(0xFFFE9901),
    );
  }
}
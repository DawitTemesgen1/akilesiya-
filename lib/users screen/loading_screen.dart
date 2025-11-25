import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/main.dart'; // For colors

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
        ),
      ),
    );
  }
}

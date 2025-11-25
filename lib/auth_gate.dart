import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/home_screen.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/start_screen.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/loading_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // 1. While the provider is checking the initial auth state, show a loading screen.
        if (userProvider.isLoading) {
          return const LoadingScreen();
        }

        // 2. If done loading and the user is logged in, show the main app.
        if (userProvider.isLoggedIn) {
          return const HomeScreen();
        }

        // 3. Otherwise, the user is logged out, so show the public start screen.
        return const StartScreen();
      },
    );
  }
}

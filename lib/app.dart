import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/pages/onboarding.page.dart';
import 'features/auth/pages/login.page.dart';
import 'features/home/pages/home.page.dart';
import 'core/utils/token_storage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isUserConnected() async {
    final token = await TokenStorage.readToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // Routes nommées !
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/onboarding': (context) => const OnboardingPage(),
      },

      home: FutureBuilder<bool>(
        future: isUserConnected(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Splash/loading
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == true) {
            return const HomePage();
          } else {
            return const OnboardingPage();
          }
        },
      ),
    );
  }
}
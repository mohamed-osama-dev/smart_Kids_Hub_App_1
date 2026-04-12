import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'features/auth/domain/models/parent.dart';
import 'features/auth/presentation/screens/screens.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'utils/splash_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartKids Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.parentInfo: (context) => const ParentInfoScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.otpVerification:
            final parent = settings.arguments as Parent?;
            if (parent != null) {
              return MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(parent: parent),
              );
            }
            break;
          case AppRoutes.childInfo:
            final parent = settings.arguments as Parent?;
            if (parent != null) {
              return MaterialPageRoute(
                builder: (context) => ChildInfoScreen(parent: parent),
              );
            }
            break;
        }
        return null;
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصفحة الرئيسية')),
      body: const Center(child: Text('مرحباً بك في SmartKids Hub!')),
    );
  }
}

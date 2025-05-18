import 'package:ppbtest/pages/home_page.dart';
import 'package:ppbtest/pages/account.dart';
import 'package:ppbtest/pages/login.dart';
import 'package:ppbtest/pages/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ppbtest/firebase_options.dart';
// import 'package:ppbtest/pages/second_screen.dart';
import 'package:ppbtest/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'home_page': (context) => const HomePage(),
        // 'second': (context) => const SecondScreen(),
        'account': (context) => const AccountDetail(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
      },
      initialRoute: 'login',
      navigatorKey: navigatorKey,
    );
  }
}

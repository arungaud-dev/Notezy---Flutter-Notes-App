import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/auth/screens/login_screen.dart';
import 'package:notes_app/auth/screens/signup_screen.dart';
import 'package:notes_app/features/home/home_screen.dart';
import 'package:notes_app/provider/auth_state_provider.dart';
import 'package:notes_app/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: ThinkNote()));
}

class ThinkNote extends StatelessWidget {
  const ThinkNote({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    return user.when(
        data: (data) {
          if (data != null) return HomeScreen();
          return LoginScreen();
        },
        error: (error, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text("Error 404"),
            ),
          );
        },
        loading: () => SplashScreen());
  }
}

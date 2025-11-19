import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/features/auth/auth_service/auth_service.dart';
import 'package:notes_app/features/auth/screens/signup_screen.dart';
import 'package:notes_app/data/firestore_service/firebase_service.dart';
import 'package:notes_app/providers/category_provider.dart';
import 'package:notes_app/providers/notes_provider.dart';
import 'package:notes_app/widgets/custom_textfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isLoading = false;
  final AuthService service = AuthService();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> loginUser() async {
    if (_emailController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')),
        );
      }
      return;
    }

    if (mounted) setState(() => isLoading = true);

    try {
      // Capture providers-backed objects BEFORE doing async login (safe)
      final firebaseService = ref.read(firebaseServicesProvider);
      final notesNotifier = ref.read(notesProvider.notifier);
      final category = ref.read(categoryHandler.notifier);

      // 1) perform login
      final loginMsg = await service.loginUser(
        _emailController.text.trim(),
        _passController.text.trim(),
      );

      if (loginMsg != null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(loginMsg)));
        }
        return;
      }

      // 2) reload firebase user so displayName/uid available
      await FirebaseAuth.instance.currentUser?.reload();
      debugPrint('loginUser: FirebaseAuth.currentUser -> '
          '${FirebaseAuth.instance.currentUser?.uid} / ${FirebaseAuth.instance.currentUser?.displayName}');

      // IMPORTANT: DO NOT call ref.refresh(authStateProvider) here because
      // authState change may have already disposed this widget.
      // ref.refresh(authStateProvider); // <-- REMOVE this

      // 3) now sync using captured services (safe even if widget disposes afterward)
      await syncFirebaseToLocal(firebaseService, notesNotifier);
      await syncCategoryFireToLocal(firebaseService, category);
    } catch (e, st) {
      debugPrint('loginUser error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Try again.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      } else {
        debugPrint('loginUser: widget not mounted, skipped setState');
      }
    }
  }
  //Sync function after login

// Change signature: pass firebaseServices instance and notes notifier
  Future<void> syncFirebaseToLocal(
      FirebaseServices firebaseService, DataNotifier notesNotifier) async {
    try {
      // use FirebaseAuth directly to log uid (safe)
      final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      debugPrint('syncFirebaseToLocal: firebaseUid=$firebaseUid');

      // Use the captured firebaseService (not ref.read inside here)
      final notes = await firebaseService.getDataFromFire(0);

      if (notes.isEmpty) {
        debugPrint('syncFirebaseToLocal: no notes to sync');
        return;
      }

      for (var i = 0; i < notes.length; i++) {
        final data = notes[i];
        try {
          // call notifier (notifier was captured earlier)
          final maybeFuture = notesNotifier.addData(data);
          await Future.value(maybeFuture); // handles void or Future
        } catch (e, st) {
          debugPrint('(#${i + 1}) Writing FAILED for ${data.title}: $e\n$st');
        }
      }
    } catch (e, st) {
      debugPrint('syncFirebaseToLocal top-level error: $e\n$st');
    }
  }

  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  Future<void> syncCategoryFireToLocal(
      FirebaseServices firebaseService, CategoryNotifier category) async {
    try {
      // use FirebaseAuth directly to log uid (safe)
      final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      debugPrint('syncFirebaseToLocal: firebaseUid=$firebaseUid');

      // Use the captured firebaseService (not ref.read inside here)
      final categories = await firebaseService.getCategoryFromFire();

      if (categories.isEmpty) {
        debugPrint('syncFirebaseToLocal: no categories to sync');
        return;
      }

      for (var i = 0; i < categories.length; i++) {
        final data = categories[i];
        try {
          // call notifier (notifier was captured earlier)
          final maybeFuture = category.addCategory(data);
          await Future.value(maybeFuture); // handles void or Future
        } catch (e, _) {
          debugPrint('(#${i + 1}) CATEGORY Writing FAILED ERROR');
        }
      }
    } catch (e, st) {
      debugPrint('syncFirebaseToLocal top-level error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 163,
                    width: 216,
                    child: Image.asset(
                      "assets/images/stack.jpeg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text.rich(TextSpan(
                  text: "Log",
                  style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.green[700]),
                  children: [
                    TextSpan(
                        text: "IN",
                        style: GoogleFonts.inter(
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            color: Colors.black))
                  ])),
              SizedBox(
                height: 5,
              ),
              Text(
                "Welcome back — your ideas are waiting.",
                style: GoogleFonts.inter(
                    fontSize: 15, fontStyle: FontStyle.italic),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomInputText(
                    icon: Icons.email,
                    hint: "Enter your email",
                    isSecure: false,
                    controller: _emailController),
              ),
              SizedBox(
                height: 14,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomInputText(
                    icon: Icons.lock,
                    hint: "Enter your password",
                    isSecure: true,
                    controller: _passController),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 120,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white),
                        onPressed: isLoading == true
                            ? null
                            : () async {
                                if (!mounted) return;
                                setState(() {
                                  isLoading = true;
                                });
                                await loginUser();
                              },
                        child: Text(
                          "LOGIN",
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        )),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.inter(fontSize: 15),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()));
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700]),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

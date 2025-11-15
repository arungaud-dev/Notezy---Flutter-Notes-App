import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/data/firestore_data/firebase_services.dart';
import 'package:notes_app/providers/notes_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(notesProivder.notifier).getData("sp");
      }
    });
  }

  Future<void> syncFirebaseToLocal() async {
    if (!mounted) return;
    // final notes = await services.getDataFromFire(0);
    final notes = await ref.read(firebaseServicesProvider).getDataFromFire(0);
    debugPrint(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>DATA FOUND: $notes");
    if (notes.isEmpty) return;

    for (var data in notes) {
      // debugPrint("------------FROM FIREBASE: ${data.toMap()}");
      // await dbHelper.insertData(data);
      ref.read(notesProivder.notifier).addData(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 166,
              width: 216,
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "ThinkNote",
              style:
                  GoogleFonts.inter(fontStyle: FontStyle.italic, fontSize: 20),
            ),
            Text(
              "Think batter, note smarter",
              style:
                  GoogleFonts.inter(fontSize: 15, fontStyle: FontStyle.italic),
            ),
            SizedBox(
              height: 40,
            ),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}

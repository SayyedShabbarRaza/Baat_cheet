import 'package:BaatCheet/screens/auth.dart';
import 'package:BaatCheet/screens/chat_screen.dart';
import 'package:BaatCheet/screens/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

// a
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlutterChat",
      theme: ThemeData(  textTheme: GoogleFonts.abhayaLibreTextTheme(),
).copyWith(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor:const Color.fromARGB(255, 17, 177, 172)),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const ChatScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

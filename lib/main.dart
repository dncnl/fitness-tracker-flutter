import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// main is now async to wait for shared preferences.
void main() async {
  // This ensures that widget binding is initialized before you run the app.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get shared preferences instance.
  final prefs = await SharedPreferences.getInstance();
  // Try to get the saved user name. It will be null if it's the first time.
  final String? userName = prefs.getString('userName');

  runApp(MyApp(userName: userName));
}

class MyApp extends StatelessWidget {
  final String? userName;
  const MyApp({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // If a user name is found, go to HomeScreen. Otherwise, go to LoginScreen.
      home: userName != null ? HomeScreen(userName: userName!) : const LoginScreen(),
    );
  }
}

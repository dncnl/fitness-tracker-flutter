import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _login() async {
    if (_nameController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // Pass the name to the HomeScreen
          builder: (context) => HomeScreen(userName: _nameController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Using a SingleChildScrollView prevents the content from overflowing on smaller screens,
      // for example when the keyboard appears.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          // We use SizedBox with height to create vertical space and center the content.
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8, // Use 80% of screen height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- SVG PLACEHOLDER ---
                // This is a placeholder for a nice welcome illustration.
                // You can add an SVG image here to make the screen more engaging.
                // Example: SvgPicture.asset('assets/images/welcome_art.svg', height: 150),
                const Icon(Icons.fitness_center, size: 100, color: Color(0xFFa1c4fd)),
                const SizedBox(height: 40),

                Text("What should we call you?",
                    style: GoogleFonts.poppins(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 20),

                // --- IMPROVED TEXT FIELD ---
                // We have styled the TextField for a more modern look.
                TextField(
                  controller: _nameController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    // `filled: true` and `fillColor` give the field a background color.
                    filled: true,
                    fillColor: const Color(0xFFF7F8FF),
                    // `border` is set to `InputBorder.none` to remove the default underline.
                    // We then define a custom shape using `OutlineInputBorder`.
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- IMPROVED BUTTON ---
                // The ElevatedButton is styled to be more prominent and match the app's theme.
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D82F8), // Custom background color
                    foregroundColor: Colors.white, // Text color
                    minimumSize: const Size(double.infinity, 50), // Make the button wide and tall
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                  ),
                  child: Text("Continue", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

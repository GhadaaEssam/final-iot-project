import 'package:flutter/material.dart';
import 'SignInScreen.dart';  // Import your SignInScreen or whichever screen you want to navigate to

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main container for the screen layout
      body: Container(
        decoration: BoxDecoration(
          // Background gradient for the screen
          gradient: LinearGradient(
            colors: [Color(0xFF1C3150), Color(0xFFDBC6C0)], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                // Display an image in the center of the screen
                child: Image.asset(
                  'assets/Smart home-pana.png',  // Path to the image asset
                  width: 300,  // Set the width of the image
                  height: 300, // Set the height of the image
                ),
              ),
            ),
            // Welcome text
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10), // Add spacing between elements
            // Subtitle text
            Text(
              'Let\'s make your home comfortable',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1C3150).withOpacity(0.8),
              ),
            ),
            SizedBox(height: 40), // Add spacing before the button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              // Button to navigate to the SignInScreen
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );  // Navigate to SignInScreen
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners for the button
                  ),
                  backgroundColor: Color(0xFF1C3150), // Set the button color
                ),
                // Button label
                child: Center(
                  child: Text(
                    'Get started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 80), // Add spacing at the bottom of the screen
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homeapp/Distance.dart';
import 'package:homeapp/Door.dart';
import 'package:homeapp/Flame.dart';
import 'package:homeapp/Lamp.dart';
import 'package:homeapp/SignInScreen.dart';
import 'package:homeapp/SoilPage.dart';
import 'package:homeapp/StartPage.dart';
import 'package:homeapp/WeatherPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final Color primaryColor = Color.fromARGB(255, 6, 5, 49);  // Define the primary color
  final Color secondaryColor = Color(0xFFdbc6b0);  // Define the secondary color
  final Color accentColor = Color(0xFF78809d);  // Define an accent color
  final Color iconColor = Color(0xFF4d6489);  // Define the icon color

  bool _isPressed = false;  // Track whether an icon button is pressed
  double _scale = 1.0;  // Scale factor for icon buttons

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background decoration with a gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],  // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 114),  // Space from top

                Expanded(
                  child: Stack(
                    children: [
                      if (_isPressed)
                        Positioned.fill(
                          child: CustomPaint(),  // Custom paint effect when button is pressed
                        ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home,
                            size: 80,
                            color: Colors.white,  // Home icon in the center
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 30),  // Space before grid

                          // Grid view of buttons
                          Expanded(
                            child: GridView.count(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              crossAxisCount: 2,  // Two columns in the grid
                              crossAxisSpacing: 30,  // Spacing between columns
                              mainAxisSpacing: 30,  // Spacing between rows
                              children: [
                                // Each icon button in the grid
                                _buildIconButton(context, Icons.location_on, LocationPage(), Colors.black),
                                _buildIconButton(context, Icons.light, LightingPage(), Colors.black),
                                _buildIconButton(context, Icons.cloud, WeatherPage(), Colors.black),
                                _buildIconButton(context, Icons.door_back_door, DoorPage(), Colors.black),
                                _buildIconButton(context, Icons.eco, SoilPage(), Colors.black),
                                _buildIconButton(context, Icons.local_fire_department, FirePage(), Colors.black),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),  // Space at the bottom
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Logout icon at the top right
            Positioned(
              top: 30,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  _showLogoutDialog(context);  // Show logout dialog when tapped
                },
                child: Icon(
                  Icons.logout,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create icon buttons in the grid
  Widget _buildIconButton(BuildContext context, IconData icon, Widget page, Color iconColor) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _isPressed = true;  // Set pressed state to true
          _scale = 0.9;  // Reduce scale to indicate button press
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;  // Reset pressed state
          _scale = 1.0;  // Reset scale
        });
        _onButtonPressed(context, page);  // Navigate to the selected page
      },
      child: Transform.scale(
        scale: _scale,  // Apply scale transformation
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),  // Rounded corners
          ),
          child: Center(
            child: Icon(
              icon,  // Display the icon
              size: 50,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  // Method to navigate to a new page when an icon button is pressed
  void _onButtonPressed(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,  // Navigate to the selected page
      ),
    );
  }

  // Method to show the logout dialog
  void _showLogoutDialog(BuildContext context) {
    final _auth = FirebaseAuth.instance;  // Firebase authentication instance
    final _firestore = FirebaseFirestore.instance;  // Firestore instance

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),  // Rounded corners for the dialog
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4d6489), Color.fromARGB(255, 195, 200, 218)],  // Gradient background for the dialog
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15.0),  // Rounded corners
            ),
            padding: EdgeInsets.all(20.0),  // Padding inside the dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 15.0),
                Text(
                  "Are you sure you want to log out?",  // Logout confirmation text
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();  // Close the dialog without logging out
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    //Sign out
                    TextButton(
                      onPressed: () async {
                        await _auth.signOut();  // Sign out the user
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => StartScreen()),  // Navigate to the StartScreen after logout
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.grey),  // Logout icon
                          SizedBox(width: 4),
                          Text(
                            "Log out",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),  // Space between buttons
                //delete user
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        User? user = _auth.currentUser;  // Get the current user
                        if (user != null) {
                          await _firestore.collection('users').doc(user.uid).delete();  // Delete user data from Firestore
                          await user.delete();  // Delete the user account
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignInScreen()),  // Navigate to the Sign-In screen
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.redAccent),  // Delete account icon
                          SizedBox(width: 4),
                          Text(
                            "Delete Account",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

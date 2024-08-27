import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeapp/HomePage.dart';
import 'package:homeapp/SignUpScreen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}
//Authentication
class _SignInScreenState extends State<SignInScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Wrap everything in SingleChildScrollView
        child: Container(
          height: MediaQuery.of(context).size.height, // Ensure the container takes full screen height
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C3150), Color(0xFFDBC6C0)], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Positioned(
                  top: 60,  // Vertical position
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 200,  // Fixed width
                    height: 200, // Fixed height
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Smart home-pana.png'), // Your image path
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 160), // Adjust this to create space for the image
                    //Email
                    TextField(
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: InputDecoration(
                      hintText: 'Email', // Placeholder text
                      hintStyle: TextStyle(color: Color.fromARGB(255, 1, 19, 49)), // Hint text color
                      prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 1, 19, 49)), // Email icon inside the box
                      border: InputBorder.none, // No default border
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.0), // Thicker bottom border when not focused
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.5), // Thicker bottom border when focused
                      ),
                    ),
                    ),
                    SizedBox(height: 20),
                    //password
                    TextField(
                      onChanged: (value) {
                        password = value;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                      hintText: 'Password', // Placeholder text
                      hintStyle: TextStyle(color: Color.fromARGB(255, 1, 19, 49)), // Hint text color
                      prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 1, 19, 49)), // Password icon inside the box
                      border: InputBorder.none, // No default border
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.0), // Thicker bottom border when not focused
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.5), // Thicker bottom border when focused
                      ),
                    ),
                    ),
                    SizedBox(height: 40),
                    //sign in button
                    Positioned(  
                          child: Center(
                            child: Container(
                              width: 221,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 1, 19, 49),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(40),
                              ),
                                  child: ElevatedButton(
                                    //when the user click sign in it will show the shome page
                                    onPressed: () async {
                                      try {
                                        await _auth.signInWithEmailAndPassword(email: email, password: password);
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                    style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Don\'t have an account?',
                                  style: TextStyle(color: Color.fromARGB(255, 1, 19, 49),), 
                                
                                  ),
                                  //if he doesn't have an account it will take the user to the sign up screen
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                                  },
                                  child: Text('Sign Up',
                                  style: TextStyle(color: Color.fromARGB(255, 31, 51, 82),fontWeight: FontWeight.bold,fontSize: 15,),),
                                ),
                              ],
                            ),
                            //forgot password
                      TextButton(
                          onPressed: () async {
                            if (email.isNotEmpty) { 
                              try { //reset password message
                                await _auth.sendPasswordResetEmail(email: email);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Password reset email sent!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {  //if the user didn't write his emial
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter your email first'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color.fromARGB(255, 31, 51, 82),fontSize: 15,),
                          ),
                        ),

              
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

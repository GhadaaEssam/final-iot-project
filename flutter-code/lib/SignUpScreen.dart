import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homeapp/SignInScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}
//Firestore
class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String username = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(  // Wrap everything in SingleChildScrollView
      //background screen
        child: Container(
          height: MediaQuery.of(context).size.height,  // Ensure the container takes full screen height
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C3150), Color(0xFFDBC6C0)],  // Same gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                //image
                Positioned(
                  top: 60,  // Vertical position
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 200,  // Fixed width
                    height: 200,  // Fixed height
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Smart home-pana.png'),  // Same image path
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 160),  // Adjust this to create space for the image
                    //username
                    TextField(
                      onChanged: (value) {
                        username = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Color.fromARGB(255, 1, 19, 49)),  // Hint text color
                        prefixIcon: Icon(Icons.person, color: Color.fromARGB(255, 1, 19, 49)),  // Username icon inside the box
                        border: InputBorder.none,  // No default border
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.0),  // Thicker bottom border when not focused
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.5),  // Thicker bottom border when focused
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    //email
                    TextField(
                      onChanged: (value) {
                        email = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Color.fromARGB(255, 1, 19, 49)),  // Hint text color
                        prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 1, 19, 49)),  // Email icon inside the box
                        border: InputBorder.none,  // No default border
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.0),  // Thicker bottom border when not focused
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.5),  // Thicker bottom border when focused
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
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Color.fromARGB(255, 1, 19, 49)),  // Hint text color
                        prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 1, 19, 49)),  // Password icon inside the box
                        border: InputBorder.none,  // No default border
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.0),  // Thicker bottom border when not focused
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 1, 19, 49), width: 2.5),  // Thicker bottom border when focused
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    //sign Up button
                    Container(
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
                        //send data to firestore
                        onPressed: () async {
                          try {
                            UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            // Save the user data in Firestore
                            await _firestore.collection('users').doc(userCredential.user?.uid).set({
                              'username': username,
                              'email': email,
                            });

                            // Send email verification
                            await userCredential.user?.sendEmailVerification();

                            // Show dialog to inform the user to check their email
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Verify your email'),
                                content: Text('A verification email has been sent to $email. Please verify your email before logging in.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    //if the user whant to go to the sign Im screen
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?',
                          style: TextStyle(color: Color.fromARGB(255, 1, 19, 49),), 
                        
                          ),
                          
                        

                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                          },
                          child: Text('Sign In',
                          style: TextStyle(color: Color.fromARGB(255, 31, 51, 82),fontWeight: FontWeight.bold,fontSize: 15,),),
                        ),
                      ],
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

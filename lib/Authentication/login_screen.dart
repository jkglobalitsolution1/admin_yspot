import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Admin_panel/Admin_profile.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  bool _obscureText = true;
  // final TextEditingController _emailController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  Future<void> _loginuser(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailcontroller.text, password: _passwordcontroller.text);
      User user = userCredential.user!;

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AdminProfile(
                    user: user,
                  )));
    } catch (e) {
      print('Failed to sign in with email and password: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Invalid email or password. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF1717),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 300),
              child: DefaultTextStyle(
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w600,
                  fontSize: 25,
                  color: Colors.white,
                ),
                child: const Text("Login"),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailcontroller,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        labelText: "Enter Email or Phone number",
                        labelStyle: GoogleFonts.urbanist(color: Colors.black),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF1717)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFFF1717),
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFFF1717),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordcontroller,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.remove_red_eye_rounded,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        labelText: "Password",
                        labelStyle: GoogleFonts.urbanist(color: Colors.black),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF1717)),
                        ),
                        counterText: '',
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFFF1717),
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFFF1717),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _loginuser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1717),
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(left: 100, right: 100),
                        child: DefaultTextStyle(
                          style: GoogleFonts.urbanist(
                            fontWeight: FontWeight.normal,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          child: const Text("Login"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

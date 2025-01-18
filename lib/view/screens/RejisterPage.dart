import 'package:flutter/material.dart';
import 'package:news_app/view/screens/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Validation Logic

  bool _isSubmitted = false;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required";
    } else if (value.length < 3) {
      return "Name must be at least 3 characters";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    } else if (value != _passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  // Submit Form
  // void _submitForm() {
  //   setState(() {
  //     _isSubmitted = true;
  //   });
  //   if (_formKey.currentState!.validate()) {
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => LoginPage()));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Let's create your account",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),

                  SizedBox(height: 40),

                  // Name Field
                  TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration("Name", Icons.person),
                      validator: (value) =>
                          _isSubmitted ? _validateName(value) : null),
                  SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration("Email", Icons.email),
                      validator: (value) =>
                          _isSubmitted ? _validateEmail(value) : null),
                  SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration("Password", Icons.lock),
                      validator: (value) => _isSubmitted
                          ? _validateConfirmPassword(value)
                          : null),
                  SizedBox(height: 20),

                  // Confirm Password Field
                  TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                          "Confirm Password", Icons.lock_reset),
                      validator: (value) =>
                          _isSubmitted ? _validatePassword(value) : null),
                  SizedBox(height: 40),

                  // Register Button
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // Attempt to create a user with Firebase Authentication

                          await _auth.createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );

                          // Add user data to Firestore

                          // Display success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Account Created Successfully"),
                              backgroundColor:
                                  Colors.green, // Highlight success visually
                            ),
                          );

                          // Navigate to the LoginPage
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        } catch (e) {
                          // Display error message in Snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Failed to create account: ${e.toString()}", // Highlight specific error
                              ),
                              backgroundColor:
                                  Colors.red, // Highlight error visually
                            ),
                          );
                        }
                      }
                    },

                    // onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 120),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Sign In Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom Input Decoration
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.black),
      prefixIcon: Icon(icon, color: Colors.black),
      fillColor: Colors.grey[200],
      filled: true,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.black26, width: 2.0),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:news_app/view/screens/RejisterPage.dart';
import 'package:news_app/view/screens/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Email Validation Function
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email.";
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Please enter a valid email address.";
    }
    return null;
  }

  // Password Validation Function
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password.";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters.";
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Navigate to Task Page on successful validation
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome Back",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 30),
                  // Email TextFormField
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration("Email", Icons.email),
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  // Password TextFormField
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // Hide password
                    decoration: _inputDecoration("Password", Icons.lock),
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      print("Forgot Password clicked");
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: 40),
                  // Login Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 140),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Sign Up Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don’t have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.blue),
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
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    hintText: "Enter Password",
    labelStyle: TextStyle(color: Colors.black),
    prefixIcon: Icon( icon,color: Colors.black,),
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.grey, width: 2.0),
    ),
  );
}

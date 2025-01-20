import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:news_app/view/screens/aboutpage.dart';
import 'package:news_app/view/screens/infopage.dart';
import 'package:news_app/view/screens/loginpage.dart'; // Import LoginPage
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class AppDrawer extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    'images/man.png', // Replace with your avatar image
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder(
                  future: FirebaseAuth.instance.currentUser?.reload(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    }
                    final user = FirebaseAuth.instance.currentUser;
                    final email = user?.email ?? 'No Email Found';

                    return Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            onTap: () {
              // Handle About App navigation
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return AboutPage();
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('About Company'),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Infopage();
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'), // Add your app version here
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await _logout(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Firebase Logout
      await _auth.signOut();

      // Delete UID from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('uid');

      // Navigate to LoginPage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false, // Clear all previous routes
      );
    } catch (e) {
      // Show error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logout failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

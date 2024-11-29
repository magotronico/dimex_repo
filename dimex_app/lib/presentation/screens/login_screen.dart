import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true; // To toggle password visibility
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Construct the API URL
    final String url = 'https://dimex-api.azurewebsites.net/login/'; // Use this if you are using the Azure server

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json", // Set content type to JSON
        },
        body: json.encode({
          'id': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response body
        final responseBody = json.decode(response.body);
        final String userId = responseBody['user_id'];

        // Save the user ID to shared preferences
        await prefs.setString('userId', userId);

        // Save the login state
        await prefs.setBool('isLoggedIn', true);

        // Login successful, navigate to HomeScreen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle the case where the login failed
        setState(() {
          _errorMessage = json.decode(response.body)['detail'] ?? 'Login failed. Please try again.';
        });
        _showErrorSnackbar(_errorMessage!);
      }
    } catch (e) {
      // Handle any exceptions here
      _showErrorSnackbar('An error occurred. Please try again.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de sesión'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: Theme.of(context).cardColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/dimex_green.png', // Add your logo image here
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'ID or Email',
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  SizedBox(height: 20),
                  if (_errorMessage != null) // Display error message if available
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
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

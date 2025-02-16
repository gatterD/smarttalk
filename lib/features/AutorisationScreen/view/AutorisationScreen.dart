import 'package:flutter/material.dart';
import 'package:smarttalk/models/AutorisationHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutorisationScreen extends StatefulWidget {
  const AutorisationScreen({super.key});

  @override
  State<AutorisationScreen> createState() => _AutorisationScreenState();
}

class _AutorisationScreenState extends State<AutorisationScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username and password cannot be empty!')),
      );
      return;
    }

    final success = await _authService.login(username, password);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', success.toString());
      await prefs.setString('username', username);
      Navigator.pushNamed(context, '/friend_list');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have logged in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter username',
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter password',
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Enter'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You have no account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

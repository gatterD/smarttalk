import 'package:flutter/material.dart';
import 'package:smarttalk/models/AutorisationHelper.dart';
import 'package:smarttalk/models/User.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter username',
                labelText: 'Username',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter password',
                labelText: 'Password',
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                final user = User(
                  userName: _usernameController.text,
                  password: _passwordController.text,
                );
                final success = await _authService.login(user);

                if (success != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('token', success);
                  await prefs.setString(
                      'username', user.userName); // Сохранение имени

                  Navigator.pushNamed(context, '/friend_list');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You have logged in.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Wrong login or password!')),
                  );
                }
              },
              child: const Text('Enter')),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You have no account?'),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Register')),
            ],
          ),
        ],
      ),
    );
  }
}

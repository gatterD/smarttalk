import 'package:flutter/material.dart';
import 'package:smarttalk/functions/PasswordValidate.dart';
import 'package:smarttalk/functions/UserNameValidation.dart';
import 'package:smarttalk/models/AutorisationHelper.dart';
import 'package:smarttalk/models/User.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordSecondController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final user = User(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      debugPrint(_usernameController.text);
      final success = await _authService.register(user);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Enter username',
                ),
                validator: validateUsername,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                  ),
                  obscureText: true,
                  validator: validatePassword,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: TextFormField(
                  controller: _passwordSecondController,
                  decoration: InputDecoration(
                    hintText: 'Enter password again',
                  ),
                  validator: validatePassword,
                  obscureText: true,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (comparePasswords(_passwordController.text,
                      _passwordSecondController.text)) {
                    _register();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Passwords must be the same!')),
                    );
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

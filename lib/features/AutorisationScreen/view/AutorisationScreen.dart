import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Import Provider package
import '../bloc/AutorisationBloc.dart';
import 'package:smarttalk/provider/ThemeProvider.dart'; // Import ThemeProvider

class AutorisationScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AutorisationBloc(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Image.asset(
                        'assets/images/smarttalk_logo.png',
                        width: MediaQuery.of(context).size.width * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter username',
                        hintStyle:
                            themeProvider.currentTheme.textTheme.bodyMedium,
                      ),
                      style: themeProvider.currentTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        hintStyle:
                            themeProvider.currentTheme.textTheme.bodyMedium,
                      ),
                      style: themeProvider.currentTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 20),
                    BlocConsumer<AutorisationBloc, AutorisationState>(
                      listener: (context, state) {
                        if (state is AutorisationSuccess) {
                          Navigator.pushNamed(context, '/friend_list');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('You have logged in.')),
                          );
                        } else if (state is AutorisationFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error)),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is AutorisationLoading) {
                          return CircularProgressIndicator();
                        }
                        return ElevatedButton(
                          onPressed: () {
                            final username = _usernameController.text.trim();
                            final password = _passwordController.text.trim();

                            if (username.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Username and password cannot be empty!')),
                              );
                              return;
                            }
                            context
                                .read<AutorisationBloc>()
                                .add(LoginEvent(username, password));
                          },
                          child: const Text('Enter'),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'You have no account?',
                          style:
                              themeProvider.currentTheme.textTheme.labelMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            'Register',
                            style: themeProvider
                                .currentTheme.textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

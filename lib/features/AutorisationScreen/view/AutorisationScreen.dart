import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarttalk/theme/theme.dart';

import '../bloc/AutorisationBloc.dart';

class AutorisationScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AutorisationBloc(),
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter username',
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter password',
                  ),
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
                      style: theme.textTheme.labelMedium,
                    ),
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
      ),
    );
  }
}

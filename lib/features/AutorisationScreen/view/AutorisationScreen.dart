import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Пакет Provider
import '../bloc/AutorisationBloc.dart';
import 'package:smarttalk/provider/ThemeProvider.dart'; // Импорт ThemeProvider

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
                        hintText: 'Введите имя пользователя',
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
                        hintText: 'Введите пароль',
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
                            SnackBar(
                                content: Text('Вы успешно вошли в систему.')),
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
                                        'Имя пользователя и пароль не могут быть пустыми!')),
                              );
                              return;
                            }
                            context
                                .read<AutorisationBloc>()
                                .add(LoginEvent(username, password));
                          },
                          child: const Text('Войти'),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Нет аккаунта?',
                          style:
                              themeProvider.currentTheme.textTheme.labelMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            'Зарегистрироваться',
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smarttalk/repository/RegisterRepository.dart';
import 'package:smarttalk/services/PasswordValidate.dart';
import 'package:smarttalk/services/UserNameValidation.dart';
import 'package:smarttalk/models/AutorisationHelper.dart';
import 'package:smarttalk/features/RegisterScreen/bloc/RegisterBloc.dart';
import 'package:smarttalk/provider/ThemeProvider.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordSecondController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Register'),
            titleTextStyle: themeProvider.currentTheme.textTheme.headlineLarge,
          ),
          body: BlocProvider(
            create: (context) => RegisterBloc(
                authService: AuthService(), repository: RegisterRepository()),
            child: BlocListener<RegisterBloc, RegisterState>(
              listener: (context, state) {
                if (state is RegisterSuccess) {
                  // После успешной регистрации создаем беседу
                  context
                      .read<RegisterBloc>()
                      .add(RegisterFavoriteChatCreation());

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration successful')),
                  );

                  // Можно добавить навигацию на другой экран после создания беседы
                  // Navigator.pushReplacement(context, ...);
                } else if (state is RegisterFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error)),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Form(
                  key: _formKey,
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
                      _buildUsernameField(themeProvider),
                      const SizedBox(height: 20),
                      _buildPasswordField(themeProvider),
                      const SizedBox(height: 20),
                      _buildPasswordConfirmationField(themeProvider),
                      const SizedBox(height: 20),
                      _buildRegisterButton(context, themeProvider),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsernameField(ThemeProvider themeProvider) {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(
        hintText: 'Enter username',
        hintStyle: themeProvider.currentTheme.textTheme.bodyMedium,
      ),
      style: themeProvider.currentTheme.textTheme.bodyMedium,
      validator: validateUsername,
    );
  }

  Widget _buildPasswordField(ThemeProvider themeProvider) {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        hintText: 'Enter password',
        hintStyle: themeProvider.currentTheme.textTheme.bodyMedium,
      ),
      style: themeProvider.currentTheme.textTheme.bodyMedium,
      obscureText: true,
      validator: validatePassword,
    );
  }

  Widget _buildPasswordConfirmationField(ThemeProvider themeProvider) {
    return TextFormField(
      controller: _passwordSecondController,
      decoration: InputDecoration(
        hintText: 'Enter password again',
        hintStyle: themeProvider.currentTheme.textTheme.bodyMedium,
      ),
      style: themeProvider.currentTheme.textTheme.bodyMedium,
      validator: (value) {
        final passwordError = validatePassword(value);
        if (passwordError != null) return passwordError;
        if (value != _passwordController.text) {
          return 'Passwords must match';
        }
        return null;
      },
      obscureText: true,
    );
  }

  Widget _buildRegisterButton(
      BuildContext context, ThemeProvider themeProvider) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state is RegisterLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    context.read<RegisterBloc>().add(
                          RegisterSubmitted(
                            username: _usernameController.text,
                            password: _passwordController.text,
                          ),
                        );
                  }
                },
          style: ElevatedButton.styleFrom(
            textStyle: themeProvider.currentTheme.textTheme.labelLarge,
          ),
          child: state is RegisterLoading
              ? const CircularProgressIndicator()
              : const Text('Register'),
        );
      },
    );
  }
}

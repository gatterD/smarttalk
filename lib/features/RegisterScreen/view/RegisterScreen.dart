import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarttalk/services/PasswordValidate.dart';
import 'package:smarttalk/services/UserNameValidation.dart';
import 'package:smarttalk/models/AutorisationHelper.dart';
import 'package:smarttalk/features/RegisterScreen/bloc/RegisterBloc.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordSecondController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocProvider(
        create: (context) => RegisterBloc(
          authService: AuthService(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUsernameField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildPasswordConfirmationField(),
                const SizedBox(height: 20),
                _buildRegisterButton(context),
                _buildBlocListener(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        hintText: 'Enter username',
      ),
      validator: validateUsername,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
        hintText: 'Enter password',
      ),
      obscureText: true,
      validator: validatePassword,
    );
  }

  Widget _buildPasswordConfirmationField() {
    return TextFormField(
      controller: _passwordSecondController,
      decoration: const InputDecoration(
        hintText: 'Enter password again',
      ),
      validator: validatePassword,
      obscureText: true,
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state is RegisterLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    if (comparePasswords(_passwordController.text,
                        _passwordSecondController.text)) {
                      context.read<RegisterBloc>().add(
                            RegisterSubmitted(
                              username: _usernameController.text,
                              password: _passwordController.text,
                            ),
                          );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Passwords must be the same!')),
                      );
                    }
                  }
                },
          child: state is RegisterLoading
              ? const CircularProgressIndicator()
              : const Text('Register'),
        );
      },
    );
  }

  Widget _buildBlocListener() {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful')),
          );
        } else if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}

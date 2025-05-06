import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smarttalk/features/UserSettingsScreen/bloc/UserSettingsBloc.dart';
import 'package:smarttalk/provider/ThemeProvider.dart';
import 'package:smarttalk/repository/UserSettingsRepository.dart';

class UserSettingsScreen extends StatelessWidget {
  final int userId;

  const UserSettingsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserSettingsBloc(
        repository: UserSettingsRepository(),
      )..add(LoadPhotoEvent(userId)),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Настройки профиля',
                style: themeProvider.currentTheme.textTheme.headlineLarge,
              ),
            ),
            body: _ProfileSettingsContent(
              userId: userId,
              themeProvider: themeProvider,
            ),
          );
        },
      ),
    );
  }
}

class _ProfileSettingsContent extends StatelessWidget {
  final int userId;
  final ThemeProvider themeProvider;

  const _ProfileSettingsContent({
    required this.userId,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ProfilePhotoSection(
            userId: userId,
            themeProvider: themeProvider,
          ),
          const SizedBox(height: 24),
          _buildOtherSettings(),
        ],
      ),
    );
  }

  Widget _buildOtherSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Другие настройки',
          style: themeProvider.currentTheme.textTheme.headlineLarge,
        ),
        // Другие элементы настроек...
      ],
    );
  }
}

class _ProfilePhotoSection extends StatelessWidget {
  final int userId;
  final ThemeProvider themeProvider;

  const _ProfilePhotoSection({
    required this.userId,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSettingsBloc, UserSettingsState>(
      builder: (context, state) {
        Uint8List? photoData;
        if (state is PhotoLoaded) {
          photoData = state.photoData;
        }

        return Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: themeProvider.currentColorTheme.lightBackGround,
              backgroundImage:
                  photoData != null ? MemoryImage(photoData) : null,
              child: photoData == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: themeProvider.currentColorTheme.lightTextFaded,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickImage(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.currentColorTheme.accent,
              ),
              child: Text(
                'Изменить фото',
                style: themeProvider.currentTheme.textTheme.labelMedium,
              ),
            ),
            if (state is UserProfileLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
            if (state is UserProfileError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  state.message,
                  style: themeProvider.currentTheme.textTheme.labelMedium
                      ?.copyWith(
                    color: themeProvider.currentColorTheme.red,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      context.read<UserSettingsBloc>().add(
            UploadPhotoEvent(
              userId: userId,
              imageFile: File(pickedFile.path),
            ),
          );
    }
  }
}

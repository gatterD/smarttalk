part of 'RegisterBloc.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class AddingFavoriteChat extends RegisterState {}

class AddedFavoriteChat extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String error;

  const RegisterFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class RegisterCreatingFavoritesSuccess extends RegisterState {}

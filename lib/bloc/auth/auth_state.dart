part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {}

class AuthInitialState extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoadingState extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthSuccessState extends AuthState {
  final dynamic response;

  AuthSuccessState(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

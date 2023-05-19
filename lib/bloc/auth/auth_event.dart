part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [];
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthRegisterEvent(this.name, this.email, this.password);

  @override
  List<Object?> get props => [];
}

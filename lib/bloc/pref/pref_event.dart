part of 'pref_bloc.dart';

abstract class PrefEvent extends Equatable {
  const PrefEvent();
}

class PrefSetLoggedDataEvent extends PrefEvent {
  final String name;
  final String accessToken;
  final bool isLogged;
  final String message;

  const PrefSetLoggedDataEvent({
    required this.name,
    required this.accessToken,
    required this.isLogged,
    required this.message,
  });

  @override
  List<Object?> get props => [];
}

class PrefGetLoggedDataEvent extends PrefEvent {
  @override
  List<Object?> get props => [];
}

class PrefSetNameEvent extends PrefEvent {
  final String name;

  const PrefSetNameEvent({required this.name});

  @override
  List<Object?> get props => [];
}

class PrefSetAccessTokenEvent extends PrefEvent {
  final String accessToken;

  const PrefSetAccessTokenEvent({required this.accessToken});

  @override
  List<Object?> get props => [];
}

class PrefSetIsLoggedEvent extends PrefEvent {
  final bool isLogged;

  const PrefSetIsLoggedEvent({required this.isLogged});

  @override
  List<Object?> get props => [];
}

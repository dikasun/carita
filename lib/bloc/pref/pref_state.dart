part of 'pref_bloc.dart';

abstract class PrefState extends Equatable {
  const PrefState();
}

class PrefInitialState extends PrefState {
  @override
  List<Object> get props => [];
}

class PrefSuccessState extends PrefState {
  final String? name;
  final String? accessToken;
  final bool? isLogged;
  final String? message;

  const PrefSuccessState(
    this.message,
    this.name,
    this.accessToken,
    this.isLogged,
  );

  @override
  List<Object> get props => [];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/auth_repository.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitialState()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final login = await _authRepository.loginAuth(event.email, event.password);
        emit(AuthSuccessState(login));
      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });

    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final register = await _authRepository.registerAuth(event.name, event.email, event.password);
        emit(AuthSuccessState(register));
      } catch (e) {
        emit(AuthErrorState(e.toString()));
      }
    });
  }
}

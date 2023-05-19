import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/pref_repository.dart';

part 'pref_event.dart';

part 'pref_state.dart';

class PrefBloc extends Bloc<PrefEvent, PrefState> {
  final PreferenceRepository _prefRepository;

  PrefBloc(this._prefRepository) : super(PrefInitialState()) {
    on<PrefSetLoggedDataEvent>((event, emit) async {
      _prefRepository.setName(event.name);
      _prefRepository.setAccessToken(event.accessToken);
      _prefRepository.setIsLogged(event.isLogged);
      emit(PrefSuccessState(event.message, null, null, null));
    });

    on<PrefGetLoggedDataEvent>((event, emit) async {
      final name = await _prefRepository.getNamePref();
      final accessToken = await _prefRepository.getAccessTokenPref();
      final isLogged = await _prefRepository.getIsLoggedPref();
      emit(PrefSuccessState(null, name, accessToken, isLogged));
    });
  }
}

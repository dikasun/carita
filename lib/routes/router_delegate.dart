import 'package:carita/bloc/auth/auth_bloc.dart';
import 'package:carita/bloc/pref/pref_bloc.dart';
import 'package:carita/bloc/story/story_bloc.dart';
import 'package:carita/data/network/api/api_service.dart';
import 'package:carita/data/repository/auth_repository.dart';
import 'package:carita/data/repository/pref_repository.dart';
import 'package:carita/data/repository/story_repository.dart';
import 'package:carita/routes/page_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/local/preference/preference_helper.dart';
import '../presentation/component/loading_dialog.dart';
import '../presentation/component/warning_dialog.dart';
import '../presentation/screen/auth/login_screen.dart';
import '../presentation/screen/auth/register_screen.dart';
import '../presentation/screen/story/create_story_screen.dart';
import '../presentation/screen/story/detail_screen.dart';
import '../presentation/screen/story/home_screen.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorState;
  final PreferenceHelper preferenceHelper;

  MyRouterDelegate(
    this.preferenceHelper,
  ) : _navigatorState = GlobalKey<NavigatorState>() {
    _init();
    notifyListeners();
  }

  _init() async {
    isLogged = await preferenceHelper.getIsLogged;
    notifyListeners();
  }

  List<Page> historyStack = [];
  bool isLogged = false;

  String? selectedStory;
  String? errorMessage;
  bool isLoading = false;
  bool isCreateStory = false;
  bool isRegister = false;

  @override
  Widget build(BuildContext context) {
    historyStack = isLogged == true ? _loggedInStack : _loggedOutStack;

    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);

        if (!didPop) return false;
        if (route.settings.name == "loading") {
          isLoading = false;
        } else if (route.settings.name != null &&
            route.settings.name!.contains("error")) {
          errorMessage = null;
        } else {
          selectedStory = null;
          isCreateStory = false;
          isRegister = false;
        }

        context.read<PageManager>().returnData("popped");
        notifyListeners();

        return true;
      },
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorState;

  @override
  Future<void> setNewRoutePath(configuration) async {
    // nothing
  }

  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginScreen"),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (BuildContext context) => AuthBloc(
                  AuthRepository(
                    apiService: ApiService(Dio()),
                  ),
                ),
              ),
              BlocProvider<PrefBloc>(
                create: (BuildContext context) => PrefBloc(
                  PreferenceRepository(
                    preferenceHelper: preferenceHelper,
                  ),
                ),
              ),
            ],
            child: LoginScreen(
              onLoading: () {
                isLoading = true;
                notifyListeners();
              },
              onLoaded: () {
                isLoading = false;
                notifyListeners();
              },
              onSubmit: () async {
                isLogged = await preferenceHelper.getIsLogged;
                notifyListeners();
              },
              onRegister: () {
                isRegister = true;
                notifyListeners();
              },
              onError: (message) {
                errorMessage = message;
                notifyListeners();
              },
            ),
          ),
        ),
        if (isRegister)
          MaterialPage(
            key: const ValueKey("RegisterScreen"),
            child: BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                AuthRepository(
                  apiService: ApiService(Dio()),
                ),
              ),
              child: RegisterScreen(
                onLoading: () {
                  isLoading = true;
                  notifyListeners();
                },
                onLoaded: () {
                  isLoading = false;
                  notifyListeners();
                },
                onSubmit: () {
                  isRegister = false;
                  notifyListeners();
                },
                onLogin: () {
                  isRegister = false;
                  notifyListeners();
                },
                onError: (message) {
                  errorMessage = message;
                  notifyListeners();
                },
              ),
            ),
          ),
        if (isLoading) const LoadingPage(),
        if (errorMessage != null)
          WarningDialogPage(
            message: errorMessage!,
            onDismiss: () {
              errorMessage = null;
              notifyListeners();
            },
          ),
      ];

  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("HomeScreen"),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => StoryBloc(
                  StoryRepository(
                    apiService: ApiService(Dio()),
                  ),
                ),
              ),
              BlocProvider<PrefBloc>(
                create: (BuildContext context) => PrefBloc(
                  PreferenceRepository(
                    preferenceHelper: preferenceHelper,
                  ),
                ),
              ),
            ],
            child: HomeScreen(
              onLoading: () {
                isLoading = true;
                notifyListeners();
              },
              onLoaded: () {
                isLoading = false;
                notifyListeners();
              },
              toDetailScreen: (storyId) {
                selectedStory = storyId;
                notifyListeners();
              },
              toCreateStoryScreen: () {
                isCreateStory = true;
                notifyListeners();
              },
              onLogout: () async {
                preferenceHelper.clearPrefs();
                isLogged = await preferenceHelper.getIsLogged;
                notifyListeners();
              },
              onError: (message) {
                errorMessage = message;
                notifyListeners();
              },
            ),
          ),
        ),
        if (selectedStory != null)
          MaterialPage(
            key: ValueKey(selectedStory),
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => StoryBloc(
                    StoryRepository(
                      apiService: ApiService(Dio()),
                    ),
                  ),
                ),
                BlocProvider<PrefBloc>(
                  create: (BuildContext context) => PrefBloc(
                    PreferenceRepository(
                      preferenceHelper: preferenceHelper,
                    ),
                  ),
                ),
              ],
              child: DetailScreen(
                onLoading: () {
                  isLoading = true;
                  notifyListeners();
                },
                onLoaded: () {
                  isLoading = false;
                  notifyListeners();
                },
                onBack: () {
                  selectedStory = null;
                  notifyListeners();
                },
                storyId: selectedStory!,
                onError: (message) {
                  errorMessage = message;
                  notifyListeners();
                },
              ),
            ),
          ),
        if (isCreateStory)
          MaterialPage(
            key: const ValueKey("CreateStoryScreen"),
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => StoryBloc(
                    StoryRepository(
                      apiService: ApiService(Dio()),
                    ),
                  ),
                ),
                BlocProvider<PrefBloc>(
                  create: (BuildContext context) => PrefBloc(
                    PreferenceRepository(
                      preferenceHelper: preferenceHelper,
                    ),
                  ),
                ),
              ],
              child: CreateStoryScreen(
                onLoading: () {
                  isLoading = true;
                  notifyListeners();
                },
                onLoaded: () {
                  isLoading = false;
                  notifyListeners();
                },
                onBack: () {
                  isCreateStory = false;
                  notifyListeners();
                },
                onSend: () {
                  isCreateStory = false;
                  notifyListeners();
                },
                onError: (message) {
                  errorMessage = message;
                  notifyListeners();
                },
              ),
            ),
          ),
        if (isLoading) const LoadingPage(),
        if (errorMessage != null)
          WarningDialogPage(
            message: errorMessage!,
            onDismiss: () {
              errorMessage = null;
              notifyListeners();
            },
          ),
      ];
}

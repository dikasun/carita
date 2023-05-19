import 'package:carita/routes/page_manager.dart';
import 'package:carita/routes/router_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/styles.dart';
import 'data/local/preference/preference_helper.dart';

void main() {
  runApp(const CaritaApp());
}

class CaritaApp extends StatefulWidget {
  const CaritaApp({super.key});

  @override
  State<CaritaApp> createState() => _CaritaAppState();
}

class _CaritaAppState extends State<CaritaApp> {
  late MyRouterDelegate myRouterDelegate;

  @override
  void initState() {
    super.initState();

    final PreferenceHelper preferenceHelper =
        PreferenceHelper(sharedPreferences: SharedPreferences.getInstance());
    myRouterDelegate = MyRouterDelegate(preferenceHelper);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PageManager(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: backgroundColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryColor,
              onPrimary: Colors.white,
              secondary: secondaryColor,
              onSecondary: Colors.black,
              background: backgroundColor),
          buttonTheme: const ButtonThemeData(
            buttonColor: primaryColor,
            disabledColor: Colors.white30,
            focusColor: primaryAccentColor,
            hoverColor: primaryAccentColor,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
            focusColor: primaryAccentColor,
            hoverColor: primaryAccentColor,
          ),
        ),
        home: Router(
          routerDelegate: myRouterDelegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}

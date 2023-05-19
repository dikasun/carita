import 'package:carita/bloc/auth/auth_bloc.dart';
import 'package:carita/bloc/pref/pref_bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../routes/page_manager.dart';
import '../../component/header_widget.dart';

class LoginScreen extends StatefulWidget {
  final Function onLoading;
  final Function onLoaded;
  final Function onSubmit;
  final Function onRegister;
  final Function(String message) onError;

  const LoginScreen({
    Key? key,
    required this.onLoading,
    required this.onLoaded,
    required this.onSubmit,
    required this.onRegister,
    required this.onError,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool validateForm() {
    final FormState? form = _formKey.currentState;
    return (form != null && form.validate());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoadingState) {
              widget.onLoading();
            } else if (state is AuthSuccessState) {
              widget.onLoaded();

              BlocProvider.of<PrefBloc>(context).add(PrefSetLoggedDataEvent(
                  name: state.response.loginResult.name,
                  accessToken: state.response.loginResult.token,
                  isLogged: state.response.loginResult.name != null &&
                      state.response.loginResult.token != null,
                  message: state.response.message));
            } else if (state is AuthErrorState) {
              widget.onLoaded();
              widget.onError(state.message);
            }
          },
        ),
        BlocListener<PrefBloc, PrefState>(
          listener: (context, state) {
            if (state is PrefSuccessState) {
              final scaffoldMessengerState = ScaffoldMessenger.of(context);
              scaffoldMessengerState.showSnackBar(
                SnackBar(
                  content: Text(state.message.toString()),
                ),
              );

              widget.onSubmit();
            }
          },
        ),
      ],
      child: _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: 70.0,
            horizontal: 20.0,
          ),
          children: [
            const HeaderWidget(
              title: 'Login',
              descTitle: 'Welcome Back!',
              descSubtitle: 'Ready to explore stories?!',
            ),
            const SizedBox(
              height: 64.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      autofocus: false,
                      maxLines: 1,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.email_outlined,
                        ),
                        hintText: 'Email',
                        labelText: 'Email',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      validator: (value) {
                        return (value != null && EmailValidator.validate(value))
                            ? null
                            : 'Email is not valid.';
                      },
                    ),
                    const SizedBox(
                      height: 18.0,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      autofocus: false,
                      maxLines: 1,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.key_rounded,
                        ),
                        hintText: 'Password',
                        labelText: 'Password',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      validator: (value) {
                        return (value != null &&
                                value.length >= 8 &&
                                !value.contains(' '))
                            ? null
                            : 'Password is not valid.';
                      },
                    ),
                    const SizedBox(
                      height: 64.0,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => validateForm()
                                ? BlocProvider.of<AuthBloc>(context)
                                    .add(AuthLoginEvent(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ))
                                : null,
                            child: const Text(
                              'Login',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextButton(
                      onPressed: () async {
                        final scaffoldMessengerState =
                            ScaffoldMessenger.of(context);
                        final pageManager = context.read<PageManager>();

                        widget.onRegister();

                        final dataString = await pageManager.waitForResult();

                        scaffoldMessengerState.showSnackBar(
                          SnackBar(
                            content: Text(
                              dataString,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Don\'t have an account? Register here',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

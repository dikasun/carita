import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> showLoadingDialog(
  BuildContext dialogContext,
) async {
  return showDialog(
    context: dialogContext,
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    builder: (context) {
      return Lottie.asset(
        "assets/lottie/loading.json",
        repeat: true,
      );
    },
  );
}

class LoadingPage extends Page {
  const LoadingPage() : super(key: const ValueKey("loading"), name: "loading");

  @override
  Route createRoute(BuildContext context) {
    return DialogRoute(
      settings: this,
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Lottie.asset(
          "assets/lottie/loading.json",
          repeat: true,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> showWarningDialog(
  BuildContext context,
  String message,
) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Error',
          style: TextStyle(
              color: Colors.red.shade500, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              "assets/lottie/error.json",
              repeat: true,
            ),
            const SizedBox(
              height: 18.0,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade500,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                (states) => Colors.red.shade500,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Dismiss',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class WarningDialogPage extends Page {
  final String message;

  WarningDialogPage({
    required this.message,
  }) : super(key: ValueKey("error/$message"), name: "error");

  @override
  Route createRoute(BuildContext context) {
    return DialogRoute(
      settings: this,
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(
                color: Colors.red.shade500, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red.shade100,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                "assets/lottie/error.json",
                repeat: true,
              ),
              const SizedBox(
                height: 18.0,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade500,
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                  (states) => Colors.red.shade500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Dismiss',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

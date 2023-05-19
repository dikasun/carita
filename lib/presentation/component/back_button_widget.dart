import 'package:flutter/material.dart';

class BackButtonWidget extends StatefulWidget {
  final Function onBack;

  const BackButtonWidget({
    super.key,
    required this.onBack,
  });

  @override
  State<BackButtonWidget> createState() => _BackButtonWidgetState();
}

class _BackButtonWidgetState extends State<BackButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.resolveWith(
          (states) => const CircleBorder(),
        ),
      ),
      onPressed: () => widget.onBack(),
      child: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
      ),
    );
  }
}

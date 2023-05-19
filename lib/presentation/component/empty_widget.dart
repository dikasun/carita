import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          "assets/lottie/box-floating.json",
          repeat: true,
        ),
        const SizedBox(
          height: 18.0,
        ),
        const Text(
          "Empty Data",
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ],
    );
  }
}

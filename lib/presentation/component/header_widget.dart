import 'package:flutter/material.dart';

class HeaderWidget extends StatefulWidget {
  final String title;
  final String descTitle;
  final String descSubtitle;

  const HeaderWidget({
    Key? key,
    required this.title,
    required this.descTitle,
    required this.descSubtitle,
  }) : super(key: key);

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 12.0,
        ),
        const Divider(
          height: 6.0,
          color: Colors.black,
        ),
        const SizedBox(
          height: 12.0,
        ),
        ListTile(
          title: Text(
            widget.descTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            widget.descSubtitle,
          ),
        ),
        const SizedBox(
          height: 12.0,
        ),
      ],
    );
  }
}

class HeaderHomeWidget extends StatefulWidget {
  final String title;
  final String descTitle;
  final String descSubtitle;
  final Function onLogout;

  const HeaderHomeWidget({
    Key? key,
    required this.title,
    required this.descTitle,
    required this.descSubtitle,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<HeaderHomeWidget> createState() => _HeaderHomeWidgetState();
}

class _HeaderHomeWidgetState extends State<HeaderHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            FilledButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.resolveWith(
                  (states) => const CircleBorder(),
                ),
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => Colors.red.shade500),
              ),
              onPressed: () => widget.onLogout(),
              child: const Icon(
                Icons.logout_rounded,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 12.0,
        ),
        const Divider(
          height: 6.0,
          color: Colors.black,
        ),
        const SizedBox(
          height: 12.0,
        ),
        ListTile(
          title: Text(
            widget.descTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            widget.descSubtitle,
          ),
        ),
        const SizedBox(
          height: 12.0,
        ),
      ],
    );
  }
}

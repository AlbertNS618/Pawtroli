import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final double height;
  final double width;

  const LogoHeader({super.key, this.height = 100, this.width = 240});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(16, 48, 95, 1),
      child: Image.asset(
        'assets/images/logo.png',
        height: height,
        width: width,
      ),
    );
  }
}

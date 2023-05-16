import 'package:cmtchat_app/theme.dart';
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: isLightTheme(context)
          ? Image.asset('assets/logo.png', fit: BoxFit.contain)
          : Image.asset('asset/logo.png', fit: BoxFit.contain)
    );
  }
}

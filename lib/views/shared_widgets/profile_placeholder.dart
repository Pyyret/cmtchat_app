import 'package:cmtchat_app/colors.dart';
import 'package:cmtchat_app/theme.dart';
import 'package:flutter/material.dart';

class ProfilePlaceholder extends StatelessWidget {
  final double size;

  const ProfilePlaceholder(this.size, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      child: Material(
        color: isLightTheme(context) ? const Color(0xFFF2F2F2) : const Color(0xFF211E1E),
        borderRadius: BorderRadius.circular(size),
        child: InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: () {},
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.person_outline_rounded,
              size: size,
              color: isLightTheme(context) ? kIconLight : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

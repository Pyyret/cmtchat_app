import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

const appBarTheme = AppBarTheme(
  centerTitle: false,
  elevation: 8,
  backgroundColor: Colors.blueGrey,
  titleTextStyle: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 50,
  ),
  toolbarTextStyle: TextStyle(
    color: Colors.black87,
    fontWeight: FontWeight.bold,
    fontSize: 30,
  ),
);

final tabBarTheme = TabBarTheme(
  labelColor: Colors.black,
  unselectedLabelColor: Colors.black54,
  indicatorSize: TabBarIndicatorSize.label,
  indicator: BoxDecoration(
    color: Colors.blueGrey,
    borderRadius: BorderRadius.circular(8.0),
  ),
);


final dividerTheme = const DividerThemeData().copyWith(thickness: 1.0, indent: 75.0);

ThemeData lightTheme(BuildContext context) => ThemeData.light().copyWith(
  primaryColor: kPrimary,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: appBarTheme,
  tabBarTheme: tabBarTheme,
  dividerTheme: dividerTheme.copyWith(color: kIconLight),
  iconTheme: const IconThemeData(color: kIconLight),
  textTheme: GoogleFonts.comfortaaTextTheme(Theme.of(context).textTheme)
      .apply(displayColor: Colors.black),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

ThemeData darkTheme(BuildContext context) => ThemeData.dark().copyWith(
    primaryColor: kPrimary,
    scaffoldBackgroundColor: Colors.black,
    tabBarTheme: tabBarTheme.copyWith(unselectedLabelColor: Colors.white70),
    appBarTheme: appBarTheme.copyWith(backgroundColor: kAppBarDark),
    dividerTheme: dividerTheme.copyWith(color: kBubbleDark),
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: GoogleFonts.comfortaaTextTheme(Theme.of(context).textTheme)
        .apply(displayColor: Colors.white),
    visualDensity: VisualDensity.adaptivePlatformDensity);

bool isLightTheme(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light;
}
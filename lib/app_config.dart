import 'package:bobi_pay_out/model/constant.dart';
import 'package:flutter/material.dart';

/// A particular configuration of the app.
class AppConfig {
  final String appName;
  final String appLink;
  final ThemeData theme;
  final bool debugShowCheckedModeBanner;

  AppConfig({
    required this.appName,
    required this.appLink,
    required this.theme,
    required this.debugShowCheckedModeBanner,
  });
}

/// The default configuration of the app.
AppConfig get defaultConfig {
  return AppConfig(
    appName: 'Charts Gallery',
    appLink: '',
    theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: mainColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: mainColor,
        )),
    debugShowCheckedModeBanner: false,
  );
}

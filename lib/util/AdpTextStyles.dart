import 'package:adjeminpay_flutter/util/AdpColors.dart';
import 'package:flutter/material.dart';

class AdpTextStyles {
  static const white_bold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: Colors.white,
  );
  static const white_medium_bold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 23,
    color: Colors.white,
  );
  static const white = TextStyle(
    color: Colors.white,
  );
  static const white_semi_bold = TextStyle(
    fontWeight: FontWeight.bold,
    // fontSize: 30,
    color: Colors.white,
  );

  static const primary_bold = TextStyle(
    fontWeight: FontWeight.bold,
    // fontSize: 30,
    color: AdpColors.primary,
  );
  static const primary_bolder = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: AdpColors.primary,
  );
  static const accent_bold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30,
    color: AdpColors.accent,
  );
  static const error = TextStyle(
    fontWeight: FontWeight.bold,
    // fontSize: 30,
    color: AdpColors.red,
  );
  static const error_semi_bold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: AdpColors.red,
  );
  static const error_bold = TextStyle(
    fontWeight: FontWeight.bold,
    // fontSize: 30,
    fontSize: 26,
    color: AdpColors.red,
  );
}
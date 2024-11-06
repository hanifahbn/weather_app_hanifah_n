import 'package:flutter/material.dart';

class AppColors {
  static const Color _pureLight = Color(0xFFFFEBD0);
  static const Color _denimLight = Color(0xFF173B61);

  static const Color _pureDark = Color(0xFF173B61);
  static const Color _denimDark = Color(0xFFFFEBD0);

  static Color get pure {
    return isDarkMode ? _pureDark : _pureLight;
  }

  static Color get denim {
    return isDarkMode ? _denimDark : _denimLight;
  }

  static bool isDarkMode = false;
}

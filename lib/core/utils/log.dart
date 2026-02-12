import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

class Log {
  Log._();

  static log(String message) {
    if (kDebugMode) {
      dev.log(message, name: "Log");
    }
  }
}

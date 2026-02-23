import 'dart:developer';

import 'package:flutter/foundation.dart';

void showLog(String message) {
  if (kDebugMode) {
    return log(message);
  }
}

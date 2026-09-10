import 'package:flutter/foundation.dart';

String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://localhost:3000';
  }

  return 'http://10.0.2.2:3000';
}

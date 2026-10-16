import 'package:flutter/material.dart';

import '../helpers/environments.dart';

class ApplicationConfig {
  Future<void> configure() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Environments.load('.env');
  }
}

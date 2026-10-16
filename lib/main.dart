import 'package:flutter/material.dart';
import 'app/bloc_injector.dart';
import 'app/core/config/application_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/core/database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApplicationConfig().configure();

  final prefs = await SharedPreferences.getInstance();

  await getDatabase();

  runApp(BlocInjection());
}

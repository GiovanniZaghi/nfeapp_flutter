import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_routes.dart';
import 'core/ui/app_colors.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "E-commerce",
      initialRoute: Routes.INITIAL,
      getPages: AppPages.pages,
      supportedLocales: const [Locale('pt', 'BR')],
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryColor,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.primaryLight,
          onPrimary: AppColors.textOnPrimary,
          surface: AppColors.textOnPrimary,
          error: AppColors.error,
          outline: AppColors.gray300,
          shadow: AppColors.gray500,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimary,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.textOnPrimary,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

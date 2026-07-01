import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'controllers/stock_controller.dart';
import 'screens/startup_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Register the controller once at app startup so build() never re-registers it.
  Get.lazyPut<StockController>(() => StockController());
  runApp(const StockPredictionApp());
}

class StockPredictionApp extends StatelessWidget {
  const StockPredictionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Stock Prediction Dashboard',
          theme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const StartupScreen(),
        );
      },
    );
  }
}

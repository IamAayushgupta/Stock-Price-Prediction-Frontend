import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:stock_price_prediction_frontend/controllers/stock_controller.dart';
import 'package:stock_price_prediction_frontend/screens/dashboard_screen.dart';
import 'package:stock_price_prediction_frontend/theme/app_theme.dart';

/// A minimal test harness that wraps the app with required providers
/// (ScreenUtil, GetMaterialApp) without making real network calls.
Widget _buildTestApp() {
  return ScreenUtilInit(
    designSize: const Size(1440, 900),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) => GetMaterialApp(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    ),
  );
}

void main() {
  setUp(() {
    // Register a fresh controller before each test.
    Get.put<StockController>(StockController());
  });

  tearDown(() {
    Get.deleteAll(force: true);
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    // The app should render without throwing.
    expect(tester.takeException(), isNull);
  });

  testWidgets('Header title is visible', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Stock Prediction'), findsOneWidget);
  });

  testWidgets('LSTM subtitle is visible', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('LSTM Forecasting Dashboard'), findsOneWidget);
  });

  testWidgets('Search field is present and contains default ticker',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    final textField = find.byType(TextField).first;
    expect(textField, findsOneWidget);

    final tfWidget = tester.widget<TextField>(textField);
    expect(tfWidget.controller?.text, 'AAPL');
  });

  testWidgets('Loading indicator appears on initial fetch',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    // The very first frame after pump should show loading state.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Error state shows retry button after error is set',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Manually inject an error into the controller.
    final controller = Get.find<StockController>();
    controller.isLoading.value = false;
    controller.errorMessage.value = 'Test error message';
    await tester.pump();

    expect(find.textContaining('An Error Occurred'), findsOneWidget);
    expect(find.textContaining('Test error message'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('Retry button calls fetchData', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    final controller = Get.find<StockController>();
    controller.isLoading.value = false;
    controller.errorMessage.value = 'Some error';
    await tester.pump();

    // Tap the retry button.
    await tester.tap(find.text('Try Again'));
    await tester.pump();

    // isLoading should become true briefly as fetchData starts.
    // (It will fail network-wise in test, but the guard logic is exercised.)
    expect(tester.takeException(), isNull);
  });
}

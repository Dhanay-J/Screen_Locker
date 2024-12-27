import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const platform = MethodChannel('com.example.screen_locker/device_admin');
  
  try {
    final bool isAdmin = await platform.invokeMethod('isDeviceAdmin');
    if (isAdmin) {
      await platform.invokeMethod('lockScreen');
    } else {
      await platform.invokeMethod('requestDeviceAdmin');
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
  
  runApp(const ScreenLockerApp());
}

class ScreenLockerApp extends StatelessWidget {
  const ScreenLockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SizedBox(),  // Empty screen
      ),
    );
  }
}
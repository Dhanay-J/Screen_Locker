import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ScreenLockerApp());
}

class ScreenLockerApp extends StatelessWidget {
  const ScreenLockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Locker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ScreenLockerHome(),
    );
  }
}

class ScreenLockerHome extends StatefulWidget {
  const ScreenLockerHome({super.key});

  @override
  State<ScreenLockerHome> createState() => _ScreenLockerHomeState();
}

class _ScreenLockerHomeState extends State<ScreenLockerHome> with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.screen_locker/device_admin');
  bool _isDeviceAdmin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkDeviceAdminStatus();
    _lockScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkDeviceAdminStatus() async {
    try {
      final bool result = await platform.invokeMethod('isDeviceAdmin');
      setState(() {
        _isDeviceAdmin = result;
      });
    } on PlatformException catch (e) {
      debugPrint('Error checking device admin status: ${e.message}');
    }
  }

  Future<void> _requestDeviceAdmin() async {
    try {
      final bool result = await platform.invokeMethod('requestDeviceAdmin');
      setState(() {
        _isDeviceAdmin = result;
      });
    } on PlatformException catch (e) {
      debugPrint('Error requesting device admin: ${e.message}');
    }
  }

  Future<void> _lockScreen() async {
    if (!_isDeviceAdmin) {
      return;
    }
    try {
      await platform.invokeMethod('lockScreen');
    } on PlatformException catch (e) {
      debugPrint('Error locking screen: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Locker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isDeviceAdmin 
                ? 'Device admin permission granted'
                : 'Device admin permission required',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            if (!_isDeviceAdmin)
              ElevatedButton(
                onPressed: _requestDeviceAdmin,
                child: const Text('Grant Device Admin Permission'),
              ),
            if (_isDeviceAdmin)
              ElevatedButton(
                onPressed: _lockScreen,
                child: const Text('Lock Screen'),
              ),
          ],
        ),
      ),
    );
  }
}
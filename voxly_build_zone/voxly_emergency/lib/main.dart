import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//.dart';
//_android.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Background Service
  await initializeService();

  runApp(
    const ProviderScope(
      child: VoxlyApp(),
    ),
  );
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'voxly_foreground',
      initialNotificationTitle: 'VOXLY is active',
      initialNotificationContent: 'Monitoring for phone unlocks',
      foregroundServiceTypes: [AndroidForegroundType.specialUse],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Handle Screen On Event
  service.on('screen_on').listen((event) async {
    // This is where you would launch the overlay screen.
    // For now, it will log or show a local notification as a placeholder.
    // Due to overlay plugin limitations, launching full flutter widgets from 
    // background requires SYSTEM_ALERT_WINDOW and a specific activity launcher.
    if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "VOXLY: Wake Up",
          content: "Preparing your voice update...",
        );
    }
  });

  // Background logic: Monitoring screen state or other events
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
         // Keep context alive
      }
    }
  });
}

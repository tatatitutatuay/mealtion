import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_client.dart';

final pushNotificationProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref);
});

class PushNotificationService {
  final Ref _ref;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  PushNotificationService(this._ref);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      _initialized = false;
      return;
    }

    // Local notifications setup (for foreground display)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create Android channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'mealtion_notifications',
          'Mealtion Notifications',
          importance: Importance.high,
        ));

    // Request permission on iOS
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Register token + listen for refresh
    await _registerToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((_) => _registerToken());

    // Foreground notification display
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mealtion_notifications',
            'Mealtion Notifications',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  Future<void> _registerToken() async {
    final supabase = _ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    final platform = Platform.isIOS ? 'ios' : 'android';

    await supabase.from('device_tokens').upsert({
      'user_id': userId,
      'token': token,
      'platform': platform,
    }, onConflict: 'user_id, token');
  }

  Future<void> unregisterToken() async {
    final supabase = _ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await supabase.from('device_tokens')
        .delete()
        .eq('user_id', userId)
        .eq('token', token);
  }
}

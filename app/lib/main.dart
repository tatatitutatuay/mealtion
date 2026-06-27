import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/providers/auth_provider.dart';
import 'core/push/push_notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const ProviderScope(child: MealtionApp()));
}

class MealtionApp extends ConsumerStatefulWidget {
  const MealtionApp({super.key});

  @override
  ConsumerState<MealtionApp> createState() => _MealtionAppState();
}

class _MealtionAppState extends ConsumerState<MealtionApp> {
  @override
  void initState() {
    super.initState();
    // Listen for auth state changes and init push when authenticated
    ref.listenManual(authProvider, (previous, next) {
      if (next != null) {
        ref.read(pushNotificationProvider).init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authInitProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Mealtion',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

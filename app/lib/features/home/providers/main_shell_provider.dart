import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the active tab index in MainShell.
/// Allows child screens (e.g. HomeScreen "View All") to switch tabs.
final mainShellTabIndexProvider = StateProvider<int>((ref) => 0);

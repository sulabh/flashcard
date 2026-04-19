import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/core_providers.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../presentation/screens/selection_screen.dart';
import '../../presentation/screens/subject_screen.dart';
import '../../presentation/screens/deck_list_screen.dart';
import '../../presentation/screens/study_screen.dart';
import '../../presentation/screens/session_summary_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/stats_screen.dart';
import '../../presentation/screens/card_maintenance_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            if (auth.error != null) Text(auth.error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () => ref.read(authProvider.notifier).login(usernameController.text, passwordController.text),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Protect downstream sub-routes from unauthorized access
      final protectedRoutes = ['/selection', '/deck', '/study'];
      if (protectedRoutes.contains(state.matchedLocation)) {
        final isLocked = ref.read(isCurrentSubjectLockedProvider);
        if (isLocked) {
          // Bounce back to subjects screen if trying to bypass lock
          return '/subjects';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/selection', 
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'study';
          return SelectionScreen(mode: mode);
        }
      ),
      GoRoute(
        path: '/subjects', 
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'study';
          return SubjectScreen(mode: mode);
        }
      ),
      GoRoute(path: '/deck', builder: (context, state) => const DeckListScreen()),
      GoRoute(path: '/study', builder: (context, state) => const StudyScreen()),
      GoRoute(path: '/summary', builder: (context, state) => const SessionSummaryScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
      GoRoute(path: '/maintenance', builder: (context, state) => const CardMaintenanceScreen()),
    ],
  );
});

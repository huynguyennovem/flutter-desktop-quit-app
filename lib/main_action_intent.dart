import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

/// The route configuration.
final GoRouter _router = GoRouter(
  navigatorKey: _navigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details',
          builder: (BuildContext context, GoRouterState state) {
            return const DetailsScreen();
          },
        ),
      ],
    ),
  ],
);

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

bool _isKeyboardListenerEnabled = true;

class QuitIntent extends Intent {
  const QuitIntent();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyW, meta: true): QuitIntent(),
      },
      builder: (context, child) {
        return Actions(actions: {
          QuitIntent: CallbackAction(onInvoke: (intent) => _handleIntent()),
        }, child: child ?? const SizedBox.shrink());
      },
    );
  }

  void _handleIntent() {
    if (!_isKeyboardListenerEnabled) return;
    if (_navigatorKey.currentContext == null) return;

    // show confirm dialog
    _showQuitAppConfirmationDialog(_navigatorKey.currentContext!, (confirmCallback) {
      if (confirmCallback) {
        SystemNavigator.pop(); // Quit the app
      }
      // listen keyboard again
      _isKeyboardListenerEnabled = true;
    });
  }

  void _showQuitAppConfirmationDialog(BuildContext context, Function(bool)? confirmCallback) {
    // Disable the keyboard listener.
    _isKeyboardListenerEnabled = false;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quit App'),
          content: const Text('Are you sure you want to quit the app?'),
          actions: [
            TextButton(
              onPressed: () {
                confirmCallback?.call(false);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close the app
                confirmCallback?.call(true);
              },
              child: const Text('Quit'),
            ),
          ],
        );
      },
    );
  }
}

/// The home screen
class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.go('/details'),
              child: const Text('Go to the Details screen'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details screen
class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen]
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <ElevatedButton>[
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go back to the Home screen'),
            ),
          ],
        ),
      ),
    );
  }
}

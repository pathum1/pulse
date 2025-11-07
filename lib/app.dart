import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'shared/widgets/loading_screen.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/check_in_page.dart';
import 'features/schedule/presentation/pages/schedule_page.dart';
import 'features/schedule/presentation/pages/calendar_page.dart';
import 'features/surgery/presentation/pages/surgery_details_page.dart';
import 'features/surgery/presentation/pages/create_surgery_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

/// Main App Widget for Pulse Track
class PulseTrackApp extends StatelessWidget {
  const PulseTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        // Routing configuration
        routerConfig: _router,
        
        // Builder for additional configuration
        builder: (context, child) {
          return _AppWrapper(child: child ?? const SizedBox.shrink());
        },
    );
  }
}

/// App wrapper for additional configuration
class _AppWrapper extends StatefulWidget {
  final Widget child;
  
  const _AppWrapper({required this.child});

  @override
  State<_AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<_AppWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Configure foreground notification handling
    FirebaseService.instance.configureForegroundNotificationHandling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        // App went to background
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        // App is detached
        break;
      case AppLifecycleState.inactive:
        // App is inactive
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  void _handleAppResumed() {
    // Handle app resume - check for missed notifications, sync data, etc.
    print('App resumed');
  }

  void _handleAppPaused() {
    // Handle app pause - save data, schedule notifications, etc.
    print('App paused');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// App router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    // Splash screen
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    
    // Onboarding
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    
    // Authentication
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    
    // Check-in (daily availability)
    GoRoute(
      path: '/checkin',
      name: 'checkin',
      builder: (context, state) => const CheckInPage(),
    ),
    
    // Main app shell with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        // Schedule (Home)
        GoRoute(
          path: '/schedule',
          name: 'schedule',
          builder: (context, state) => const SchedulePage(),
          routes: [
            // Surgery details
            GoRoute(
              path: '/surgery/:surgeryId',
              name: 'surgery-details',
              builder: (context, state) {
                final surgeryId = state.pathParameters['surgeryId']!;
                return SurgeryDetailsPage(surgeryId: surgeryId);
              },
            ),
          ],
        ),
        
        // Hospital calendar
        GoRoute(
          path: '/calendar',
          name: 'calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        
        // Create surgery
        GoRoute(
          path: '/create-surgery',
          name: 'create-surgery',
          builder: (context, state) => const CreateSurgeryPage(),
        ),
        
        // Profile
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
  
  // Error handling
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/schedule'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  },
  
  // Redirect logic
  redirect: (context, state) {
    final isLoggedIn = FirebaseService.instance.isSignedIn;
    final currentLocation = state.uri.toString();
    
    // Allow splash and onboarding always
    if (currentLocation == '/splash' || currentLocation == '/onboarding') {
      return null;
    }
    
    // Redirect to login if not authenticated
    if (!isLoggedIn && currentLocation != '/login') {
      return '/login';
    }
    
    // Redirect to check-in if logged in but haven't checked in today
    // This logic will be implemented with actual check-in state management
    
    return null;
  },
);

/// Main app shell with bottom navigation
class MainShell extends StatefulWidget {
  final Widget child;
  
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.schedule,
      label: 'My Schedule',
      route: '/schedule',
    ),
    NavigationItem(
      icon: Icons.calendar_month,
      label: 'Calendar',
      route: '/calendar',
    ),
    NavigationItem(
      icon: Icons.add_circle,
      label: 'New Surgery',
      route: '/create-surgery',
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          context.go(_navigationItems[index].route);
        },
        type: BottomNavigationBarType.fixed,
        items: _navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

/// Navigation item model
class NavigationItem {
  final IconData icon;
  final String label;
  final String route;
  
  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
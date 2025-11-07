import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../shared/widgets/loading_screen.dart';

/// Splash Page
/// Shows loading screen while checking authentication and initializing app
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Minimum splash screen time for better UX
      await Future.delayed(const Duration(seconds: 2));
      
      // Check authentication state
      final isAuthenticated = FirebaseService.instance.isSignedIn;
      
      if (mounted) {
        if (isAuthenticated) {
          // Check if user needs to check in for today
          final needsCheckIn = await _checkIfNeedsCheckIn();
          
          if (needsCheckIn) {
            context.go('/checkin');
          } else {
            context.go('/schedule');
          }
        } else {
          // Check if user has seen onboarding
          final hasSeenOnboarding = await _hasSeenOnboarding();
          
          if (hasSeenOnboarding) {
            context.go('/login');
          } else {
            context.go('/onboarding');
          }
        }
      }
    } catch (e) {
      print('Error during app initialization: $e');
      
      if (mounted) {
        // Show error and redirect to login
        _showErrorAndRedirect();
      }
    }
  }

  Future<bool> _checkIfNeedsCheckIn() async {
    try {
      final userId = FirebaseService.instance.currentUserId;
      if (userId == null) return true;
      
      // Get surgeon document
      final surgeonDoc = await FirebaseService.instance.firestore
          .collection('surgeons')
          .doc(userId)
          .get();
      
      if (!surgeonDoc.exists) {
        // Create surgeon profile
        await _createSurgeonProfile(userId);
        return true;
      }
      
      final surgeonData = surgeonDoc.data()!;
      final lastCheckIn = surgeonData['lastCheckIn']?.toDate();
      final isAvailableToday = surgeonData['isAvailableToday'] ?? false;
      
      // Check if surgeon has checked in today
      if (lastCheckIn == null || !_isToday(lastCheckIn) || !isAvailableToday) {
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error checking check-in status: $e');
      return true;
    }
  }

  Future<void> _createSurgeonProfile(String userId) async {
    try {
      final user = FirebaseService.instance.currentUser;
      if (user == null) return;
      
      // Create initial surgeon profile
      await FirebaseService.instance.firestore
          .collection('surgeons')
          .doc(userId)
          .set({
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'Unknown',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'specialization': '',
        'isAvailableToday': false,
        'lastCheckIn': null,
        'totalSurgeriesCompleted': 0,
        'currentStatus': 'on_leave',
        'certifications': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'profileImageUrl': user.photoURL,
        'notificationSettings': {
          'surgeryReminders': true,
          'overdueAlerts': true,
          'checkInReminders': true,
          'reminderMinutes': 30,
        },
      });
      
      print('Created surgeon profile for user: $userId');
    } catch (e) {
      print('Error creating surgeon profile: $e');
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  Future<bool> _hasSeenOnboarding() async {
    // Check local storage for onboarding flag
    // For now, return false to always show onboarding
    return false;
  }

  void _showErrorAndRedirect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: const Text(
          'There was an error initializing the app. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LoadingScreen(
      message: 'Initializing Pulse Track...',
    );
  }
}
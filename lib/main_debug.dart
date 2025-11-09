import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Debug version of main with detailed error logging
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print('🚀 Starting Pulse Track...');
    
    // Initialize Firebase with detailed logging
    print('📱 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Test Firebase connection
    print('🔥 Testing Firebase connection...');
    final app = Firebase.app();
    print('✅ Firebase app: ${app.name}, options: ${app.options.projectId}');
    
    runApp(const DebugApp());
  } catch (e, stackTrace) {
    print('❌ ERROR initializing app: $e');
    print('📍 Stack trace: $stackTrace');
    
    // Show error in UI
    runApp(MaterialApp(
      title: 'Pulse Track Debug',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Debug Error'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Firebase Initialization Failed:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $e',
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text(
                'Stack Trace:\n$stackTrace',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Next Steps:\n'
                '1. Create Firestore database in Firebase Console\n'
                '2. Enable Authentication (Email/Password + Google)\n'
                '3. Check google-services.json configuration',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Track Debug',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pulse Track Debug'),
          backgroundColor: const Color(0xFF009CA6),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'Firebase Initialized Successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3C7E),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ready for full app testing',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
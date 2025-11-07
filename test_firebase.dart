import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

/// Firebase connection test script
void main() async {
  print('🔥 Testing Firebase Connection...');
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Test Firestore connection
    final firestore = FirebaseFirestore.instance;
    print('📊 Testing Firestore connection...');
    
    // Try to read from a test collection (will create if doesn't exist)
    final testDoc = await firestore.collection('test').doc('connection').get();
    
    if (!testDoc.exists) {
      // Create test document
      await firestore.collection('test').doc('connection').set({
        'status': 'connected',
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection successful'
      });
      print('✅ Test document created in Firestore');
    } else {
      print('✅ Firestore connection verified - document exists');
    }
    
    // Test collection structure
    print('🏗️ Setting up initial collections...');
    
    // Create surgery types collection with initial data
    final surgeryTypesRef = firestore.collection('surgery_types');
    await surgeryTypesRef.doc('general').set({
      'name': 'General Surgery',
      'description': 'General surgical procedures',
      'estimatedDuration': 120, // minutes
      'category': 'general',
      'isActive': true,
    });
    
    await surgeryTypesRef.doc('orthopedic').set({
      'name': 'Orthopedic Surgery',
      'description': 'Bone and joint procedures',
      'estimatedDuration': 180,
      'category': 'orthopedic', 
      'isActive': true,
    });
    
    await surgeryTypesRef.doc('cardiac').set({
      'name': 'Cardiac Surgery',
      'description': 'Heart and cardiovascular procedures',
      'estimatedDuration': 240,
      'category': 'cardiac',
      'isActive': true,
    });
    
    print('✅ Initial surgery types created');
    
    print('🎉 Firebase setup complete!');
    print('');
    print('Next steps:');
    print('1. Enable Email/Password authentication in Firebase Console');
    print('2. Enable Google Sign-In in Firebase Console'); 
    print('3. Deploy Firestore security rules');
    print('4. Test authentication flow in the app');
    
  } catch (e, stackTrace) {
    print('❌ Firebase connection failed: $e');
    print('Stack trace: $stackTrace');
    print('');
    print('Troubleshooting:');
    print('1. Check google-services.json is in android/app/');
    print('2. Verify project ID matches Firebase Console');
    print('3. Ensure Firebase project has Firestore enabled');
    exit(1);
  }
}
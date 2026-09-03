import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movies_app/app/app.dart';
import 'package:movies_app/core/di/app_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Note: Authentication features will not work until you add google-services.json / GoogleService-Info.plist');
  }

  final dependencies = AppDependencies.create();
  runApp(MoviesApp(dependencies: dependencies));
}

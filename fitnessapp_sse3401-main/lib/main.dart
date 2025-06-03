import 'dart:async';

import 'package:fitnessapp/routes.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/on_boarding/on_boarding_screen.dart';
import 'package:fitnessapp/view/profile/complete_profile_screen.dart';
import 'package:fitnessapp/view/welcome/welcome_screen.dart';
import 'package:fitnessapp/view/your_goal/your_goal_screen.dart';
import 'package:fitnessapp/view/on_boarding/start_screen.dart'; // Add this import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/connectivity_service.dart';
import 'widgets/no_internet_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Update Firebase initialization
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCrAsNr6DGsguUCbs0djPuLxCkP1mKY6cs",
          authDomain: "fitnessmobile-bf260.firebaseapp.com",
          projectId: "fitnessmobile-bf260",
          storageBucket: "fitnessmobile-bf260.firebasestorage.app",
          messagingSenderId: "241480766012",
          appId: "1:241480766012:web:c88adeb0c2e206443a6939",
          measurementId: "G-9531QYF6ER"),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _hasInternet = true;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final hasInternet = await _connectivityService.checkConnectivity();
    if (mounted) {
      setState(() {
        _hasInternet = hasInternet;
      });
    }
  }

  void _listenToConnectivity() {
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (hasInternet) {
        if (mounted) {
          setState(() {
            _hasInternet = hasInternet;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _hasInternet = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness',
      debugShowCheckedModeBanner: false,
      routes: routes,
      theme: ThemeData(
          primaryColor: AppColors.primaryColor1,
          useMaterial3: true,
          fontFamily: "Poppins"),
      home: !_hasInternet
          ? NoInternetWidget(onRetry: _checkConnectivity)
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data != null) {
                  // User is logged in
                  return const DashboardScreen();
                }

                // User is not logged in
                return const OnBoardingScreen();
              },
            ),
      builder: (context, child) {
        return !_hasInternet
            ? NoInternetWidget(onRetry: _checkConnectivity)
            : child!;
      },
    );
  }
}

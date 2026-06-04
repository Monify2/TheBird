import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home_screen.dart';
import 'components/update_checker.dart';
import 'components/custom_icons.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp.router(
        title: 'TheBird',
        theme: ThemeData(
          primaryColor: const Color(0xFF5D5FEF),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        routerConfig: _router,
        builder: (context, child) {
          return UpdateChecker(child: child!);
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final contact = state.uri.queryParameters['contact'] ?? '';
        final purposeParam = state.uri.queryParameters['purpose'] ?? 'verification';
        final purpose = purposeParam == 'reset'
            ? OtpPurpose.passwordReset
            : OtpPurpose.verification;
        return OtpScreen(contact: contact, purpose: purpose);
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainScreen(),
    ),
  ],
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TheBird'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pop();
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'For You'),
              Tab(text: 'Following'),
              Tab(text: 'Community'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('For You Feed')),
            Center(child: Text('Following Feed')),
            Center(child: Text('Community Feed')),
          ],
        ),
      ),
    );
  }
}

class ProfessorAIScreen extends StatelessWidget {
  const ProfessorAIScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Professor AI'));
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Explore / Search'));
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Messages'));
}

class SpaceScreen extends StatelessWidget {
  const SpaceScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Space (Audio / Video)'));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfessorAIScreen(),
    const ExploreScreen(),
    const MessagesScreen(),
    const SpaceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5D5FEF),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            icon: ProfessorAIIcon(color: _currentIndex == 1 ? const Color(0xFF5D5FEF) : Colors.grey, size: 24),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.explore), label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
          BottomNavigationBarItem(
            icon: SpaceIcon(color: _currentIndex == 4 ? const Color(0xFF5D5FEF) : Colors.grey, size: 24),
            label: '',
          ),
        ],
      ),
    );
  }
}

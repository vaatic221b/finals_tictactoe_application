import 'package:finals_tictactoe_application/screens/home_screen.dart';
import 'package:finals_tictactoe_application/screens/login_screen.dart';
import 'package:finals_tictactoe_application/screens/register_screen.dart';
import 'package:finals_tictactoe_application/services/auth_service.dart';
import 'package:finals_tictactoe_application/services/game_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signOut();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GameService()),  // Add GameService here
      ],
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AuthWrapper: Waiting for auth state...');
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          print('AuthWrapper: Error occurred: ${snapshot.error}');
          return Scaffold(
            body: Center(child: Text('An error occurred: ${snapshot.error}')),
          );
        } else {
          User? user = snapshot.data;
          print('AuthWrapper: Current user: $user');
          return user == null ? LoginScreen() : HomeScreen();
        }
      },
    );
  }
}

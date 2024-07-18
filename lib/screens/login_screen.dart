import 'package:finals_tictactoe_application/screens/home_screen.dart';
import 'package:finals_tictactoe_application/screens/register_screen.dart';
import 'package:finals_tictactoe_application/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          backgroundImage(),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: cardForm(context),
            ),
          ),
        ],
      ),
    );
  }

  Card cardForm(BuildContext context) {
    return Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    titleText(),
                    const SizedBox(height: 40),
                    emailField(),
                    const SizedBox(height: 20),
                    passwordField(),
                    const SizedBox(height: 20),
                    loginButton(context),
                    redirectToRegister(context),
                  ],
                ),
              ),
            );
  }

  TextButton redirectToRegister(BuildContext context) {
    return TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text('Not yet registered? Sign Up'),
                  );
  }

  ElevatedButton loginButton(BuildContext context) {
    return ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      try {
                        await Provider.of<AuthService>(context, listen: false)
                            .signInWithEmailAndPassword(email, password);
                        Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (_) => HomeScreen()));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: Text('Login'),
                  );
  }

  TextField passwordField() {
    return TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  );
  }

  TextField emailField() {
    return TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.email),
                    ),
                  );
  }

  Text titleText() {
    return Text(
                    'Tic-Tac-Toe!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  );
  }

  Container backgroundImage() {
    return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        );
  }
}

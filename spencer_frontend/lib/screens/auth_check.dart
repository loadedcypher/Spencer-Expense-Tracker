import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:spencer_frontend/utils/auth_utils.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Check if the user is authenticated by verifying the JWT token
    String? token =
        await getToken(); // Implement this function to retrieve the token from secure storage
    if (token != null) {
      try {
        // Verify the token
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        // Check if the token is expired
        if (Jwt.isExpired(token)) {
          // Token is expired, navigate to the login screen
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          // Token is valid, navigate to the home screen
          setState(() {
            _isAuthenticated = true;
          });
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        // Invalid token, navigate to the login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // No token found, navigate to the login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

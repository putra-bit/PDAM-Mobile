import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authservice.dart';

class AutoLoginPage extends StatefulWidget {
  const AutoLoginPage({super.key});

  @override
  State<AutoLoginPage> createState() => _AutoLoginPageState();
}

class _AutoLoginPageState extends State<AutoLoginPage> {
  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  void autoLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final rememberMe = await authService.getRememberMe();
    await authService.checkLoginStatus();

    if (!mounted) return;

    if (authService.isLoggedIn && rememberMe) {
      Navigator.pushReplacementNamed(context, '/userHome');
    } else {
      Navigator.pushReplacementNamed(context, '/Login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pdam_mobile/MyComponent/mysnackbar.dart';
import 'package:provider/provider.dart';
import 'package:pdam_mobile/MyComponent/mytextfield.dart';
import 'package:pdam_mobile/MyComponent/waveclippet.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:pdam_mobile/MyComponent/buttonlogin.dart';
import 'package:pdam_mobile/Backend/authservice.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'users/user.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool rememberMe = false;
  bool isLoading = false;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadRememberMe();
  }

  void loadRememberMe() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final saved = await authService.getRememberMe();
    setState(() {
      rememberMe = saved;
    });
  }

  void handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final authService = Provider.of<AuthService>(context, listen: false);

    if (username.isEmpty || password.isEmpty) {
      MySnackBar.show(
        context,
        message: "Semua field harus diisi",
        type: SnackBarType.error,
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      await authService.loginWithUsernameOrEmail(
        identifier: username,
        password: password,
      );

      await authService.setRememberMe(rememberMe);

      if (!mounted) return;

      // Langsung masuk ke halaman user
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 350),
          child: Homeuser(),
        ),
      );
    } catch (e) {
      String errorMsg = "Terjadi kesalahan";

      if (e is AuthException) {
        if (e.message.contains("Invalid login credentials")) {
          errorMsg = "Username atau password salah";
        } else {
          errorMsg = e.message;
        }
      }

      MySnackBar.show(context, message: errorMsg, type: SnackBarType.error);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void handleGoogleLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() => isLoading = true);

    try {
      await authService.signInWithGoogle();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/userHome');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Google gagal: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Image.asset(
                    'assets/kantorpdam.jpeg',
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 260,
                  right: 50,
                  child: Image.asset(
                    'assets/PDAM_BALIKPAPAN_nooBG.png',
                    scale: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const TextPoppins(
              text: 'Selamat Datang!',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            const SizedBox(height: 8),
            const TextPoppins(
              text: 'Masukkan email dan kata sandi anda.',
              fontSize: 14,
              color: Colors.grey,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Username...',
                    icon: Icons.person,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  MyTextField(
                    controller: passwordController,
                    hintText: '*****',
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                          const TextPoppins(text: 'Ingat Saya', fontSize: 13),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const TextPoppins(
                          text: 'Lupa Password?',
                          fontSize: 13,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ButtonLogin(
                    text: isLoading ? 'Memuat...' : 'Masuk',
                    onPressed: isLoading ? () {} : handleLogin,
                  ),

                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset('assets/google2.png', height: 20),
                    label: const TextPoppins(
                      text: 'Lanjut dengan Google',
                      fontWeight: FontWeight.w600,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextPoppins(
                        text: 'Belum Punya Akun?',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 1),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/Signup');
                        },
                        child: TextPoppins(
                          text: "Daftar",
                          fontSize: 13,
                          color: Color(0xff003087),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

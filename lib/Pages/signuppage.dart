import 'package:flutter/material.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:pdam_mobile/MyComponent/mytextfield.dart';
import 'package:pdam_mobile/MyComponent/buttonlogin.dart';
import 'package:pdam_mobile/MyComponent/mysnackbar.dart';
import 'package:pdam_mobile/Backend/authservice.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleSignup() async {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final authService = Provider.of<AuthService>(context, listen: false);

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      MySnackBar.show(
        context,
        message: "Semua field harus diisi!",
        type: SnackBarType.error,
      );
      return;
    }

    if (password.length < 6) {
      MySnackBar.show(
        context,
        message: "Kata sandi minimal 6 karakter.",
        type: SnackBarType.error,
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final isTaken = await authService.isEmailTaken(email);
      if (isTaken) {
        MySnackBar.show(
          context,
          message: "Email sudah digunakan. Coba gunakan email lain.",
          type: SnackBarType.error,
        );
        return;
      }

      await authService.registerWithUsername(
        username: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/Login');
      MySnackBar.show(
        context,
        message: "Berhasil membuat akun. Silakan login.",
        type: SnackBarType.success,
      );
    } on AuthException catch (e) {
      MySnackBar.show(context, message: e.message, type: SnackBarType.error);
    } catch (e) {
      MySnackBar.show(
        context,
        message: "Terjadi kesalahan saat daftar: $e",
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 45),
              Image.asset('assets/PDAM_BALIKPAPAN_nooBG.png', height: 80),
              const SizedBox(height: 20),
              const TextPoppins(
                text: 'Daftar Akunmu!',
                fontSize: 25,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              const Text(
                "Buat akunmu untuk kemudahan akses\nlayanan air dari PDAM Kota Balikpapan.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              MyTextField(
                controller: nameController,
                hintText: 'Masukan Username...',
                icon: Icons.person,
              ),
              const SizedBox(height: 15),
              MyTextField(
                controller: emailController,
                hintText: "Masukkan email...",
                icon: Icons.email,
              ),
              const SizedBox(height: 15),
              MyTextField(
                controller: passwordController,
                hintText: "Masukkan kata sandi...",
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ButtonLogin(
                  text: isLoading ? 'Mendaftarkan...' : 'Daftar',
                  onPressed: isLoading ? () {} : handleSignup,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah Punya Akun? "),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/Login'),
                    child: const Text(
                      "Masuk",
                      style: TextStyle(
                        color: Color(0xff003087),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

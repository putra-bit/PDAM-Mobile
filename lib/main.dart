import 'package:flutter/material.dart';
import 'package:pdam_mobile/Pages/signuppage.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdam_mobile/Backend/authservice.dart';
import 'package:pdam_mobile/Backend/profileservice.dart'; // Import ProfileService
import 'package:pdam_mobile/Pages/loginpage.dart';
import 'package:pdam_mobile/Pages/users/user.dart';
import 'package:pdam_mobile/Backend/AutoLoginPage.dart';
import 'package:pdam_mobile/Pages/users/profile_page.dart'; // Import ProfilePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mujohlexiykfzupmqxed.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im11am9obGV4aXlrZnp1cG1xeGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM2Njk2ODgsImV4cCI6MjA2OTI0NTY4OH0.cP1I7LGj_cnrgPhKxsqdHulhU8cb8zw1hJySxOozr6k',
  );

  runApp(
    MultiProvider(
      providers: [
        // AuthService sebagai provider utama
        ChangeNotifierProvider(create: (_) => AuthService()),
        // ProfileService yang membutuhkan AuthService
        ChangeNotifierProxyProvider<AuthService, ProfileService>(
          create: (context) => ProfileService(context.read<AuthService>()),
          update: (context, authService, previousProfileService) =>
              previousProfileService ?? ProfileService(authService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDAM Mobile',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins', // Jika ada font Poppins
      ),
      initialRoute: '/autoLogin',
      routes: {
        '/Login': (context) => const Loginpage(),
        '/Signup': (context) => const Signuppage(),
        '/userHome': (context) => const Homeuser(),
        '/autoLogin': (context) => const AutoLoginPage(),
        '/profile': (context) => const ProfilePage(), // Tambahkan route profile
      },
    );
  }
}

// lib/Backend/authservice.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthService with ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _username;
  String? get username => _username;

  String? _email;
  String? get email => _email;

  int? _userId; // simpan id user_customers
  int? get userId => _userId;

  String? _photoProfile; // tambahan untuk photo_profile
  String? get photoProfile => _photoProfile;

  /// ✅ REGISTER
  Future<AuthResponse> registerWithUsername({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': username},
      );

      final user = response.user ?? supabase.auth.currentUser;
      if (user == null) {
        throw AuthException("Gagal mendaftarkan akun.");
      }

      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      final insertedUser = await supabase
          .from('user_customers')
          .insert({
            'name': username,
            'email': email,
            'password': hashedPassword,
            'token': supabase.auth.currentSession?.accessToken ?? '',
            'photo_profile': null, // default null untuk registrasi baru
          })
          .select()
          .maybeSingle();

      if (insertedUser == null) {
        throw AuthException("Gagal menyimpan data user.");
      }

      _userId = insertedUser['id'];
      _username = insertedUser['name'];
      _email = insertedUser['email'];
      _photoProfile = insertedUser['photo_profile'];

      await _setIsLogin(true);
      await _saveUserToPrefs();
      notifyListeners();

      return response;
    } catch (e) {
      throw AuthException("Register error: $e");
    }
  }

  /// ✅ LOGIN
  Future<AuthResponse?> loginWithUsernameOrEmail({
    required String identifier,
    required String password,
  }) async {
    try {
      final result = await supabase
          .from('user_customers')
          .select(
            'id, name, email, password, photo_profile',
          ) // tambah photo_profile
          .or('email.eq.$identifier,name.eq.$identifier')
          .maybeSingle();

      if (result == null) {
        throw AuthException('Nama atau Email tidak ditemukan.');
      }

      if (!BCrypt.checkpw(password, result['password'])) {
        throw AuthException("Password salah.");
      }

      final response = await supabase.auth.signInWithPassword(
        email: result['email'],
        password: password,
      );

      _userId = result['id'];
      _username = result['name'];
      _email = result['email'];
      _photoProfile = result['photo_profile'];

      await _setIsLogin(true);
      await _updateTokenByEmail(result['email']);
      await _saveUserToPrefs();
      notifyListeners();

      return response;
    } catch (e) {
      throw AuthException("Login error: $e");
    }
  }

  /// ✅ LOGIN GOOGLE
  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );

    final user = supabase.auth.currentUser;
    if (user != null) {
      _email = user.email;
      _username = user.userMetadata?['name'] ?? "User";

      // simpan ke user_customers jika belum ada
      final existing = await supabase
          .from('user_customers')
          .select('id, photo_profile') // tambah photo_profile
          .eq('email', _email ?? '')
          .maybeSingle();

      if (existing == null) {
        final inserted = await supabase
            .from('user_customers')
            .insert({
              'name': _username,
              'email': _email,
              'password': '-', // Google login tidak pakai password
              'token': supabase.auth.currentSession?.accessToken ?? '',
              'photo_profile':
                  user.userMetadata?['avatar_url'], // ambil dari Google
            })
            .select()
            .maybeSingle();

        _userId = inserted?['id'];
        _photoProfile = inserted?['photo_profile'];
      } else {
        _userId = existing['id'];
        _photoProfile = existing['photo_profile'];
      }

      await _setIsLogin(true);
      await _saveUserToPrefs();
      notifyListeners();
    }
  }

  /// ✅ LOGOUT
  Future<void> signOut() async {
    await supabase.auth.signOut();
    await _setIsLogin(false);
    _username = null;
    _email = null;
    _userId = null;
    _photoProfile = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  /// ✅ REMEMBER ME
  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rememberMe') ?? false;
  }

  /// ✅ CEK EMAIL SUDAH ADA?
  Future<bool> isEmailTaken(String email) async {
    final response = await supabase
        .from('user_customers')
        .select('id')
        .eq('email', email)
        .maybeSingle();

    return response != null;
  }

  /// ✅ SIMPAN DATA USER KE PREFS
  Future<void> _saveUserToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username ?? '');
    await prefs.setString('email', _email ?? '');
    await prefs.setInt('userId', _userId ?? -1);
    await prefs.setString('photoProfile', _photoProfile ?? '');
  }

  /// ✅ CEK STATUS LOGIN
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLogin') ?? false;

    if (_isLoggedIn) {
      _username = prefs.getString('username');
      _email = prefs.getString('email');
      _userId = prefs.getInt('userId');
      _photoProfile = prefs.getString('photoProfile');
    }

    notifyListeners();
  }

  /// ✅ SET LOGIN STATUS
  Future<void> _setIsLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', value);
    _isLoggedIn = value;
  }

  /// ✅ UPDATE TOKEN
  Future<void> _updateTokenByEmail(String email) async {
    final token = supabase.auth.currentSession?.accessToken;
    if (token != null) {
      await supabase
          .from('user_customers')
          .update({'token': token})
          .eq('email', email);
    }
  }

  /// ✅ UPDATE PHOTO PROFILE (untuk digunakan ProfileService nanti)
  Future<void> updatePhotoProfile(String? photoUrl) async {
    if (_userId != null) {
      await supabase
          .from('user_customers')
          .update({'photo_profile': photoUrl})
          .eq('id', _userId!);

      _photoProfile = photoUrl;
      await _saveUserToPrefs();
      notifyListeners();
    }
  }

  /// ✅ GETTER UNTUK AKSES PRIVATE METHODS DARI PROFILESERVICE
  // Method ini diperlukan agar ProfileService bisa akses method private
  Future<void> saveUserToPrefs() async => await _saveUserToPrefs();

  // Setter untuk username dan email (diperlukan ProfileService)
  set username(String? value) {
    _username = value;
  }

  set email(String? value) {
    _email = value;
  }

  /// ✅ CEK apakah user punya nomor sambungan
  Future<Map<String, dynamic>?> getConnectionInfo() async {
    if (_userId == null) return null;

    final rekening = await supabase
        .from('customer_rekening')
        .select('customer_id')
        .eq('user_customer_id', _userId!)
        .maybeSingle();

    if (rekening == null) return null;

    final customerId = rekening['customer_id'];

    final customer = await supabase
        .from('customers')
        .select('id, connection_number, nama, alamat')
        .eq('id', customerId)
        .maybeSingle();

    return customer; // null kalau tidak ada
  }

  /// ✅ Getter apakah user punya nomor sambungan
  Future<bool> get hasValidConnectionNumber async {
    final info = await getConnectionInfo();
    return info != null;
  }
}

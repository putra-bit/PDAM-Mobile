// lib/Pages/users/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdam_mobile/Pages/loginpage.dart';
import 'package:provider/provider.dart';
import 'package:pdam_mobile/Backend/authservice.dart';
import 'package:pdam_mobile/Backend/profileservice.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';
import 'package:pdam_mobile/MyComponent/mysnackbar.dart';
import 'package:page_transition/page_transition.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _pickedImage;

  // PDAM Color Scheme
  static const Color pdamPrimary = Color(0xFF0277BD); // Blue PDAM
  static const Color pdamSecondary = Color(0xFF4FC3F7); // Light Blue
  static const Color pdamSuccess = Color(0xFF2E7D32); // Green
  static const Color pdamBackground = Color(
    0xFFF3F8FB,
  ); // Light Blue Background
  static const Color pdamCard = Color(0xFFFFFFFF); // White Card
  static const Color pdamText = Color(0xFF263238); // Dark Text

  void _signOutTrasisi() {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 350),
        child: Loginpage(),
      ),
    );
  }

  Future<void> _showImageSourceDialog(ProfileService profile) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: pdamCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Pilih Foto Profil",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: pdamText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageOption(
                          icon: Icons.photo_library_rounded,
                          title: "Galeri",
                          onTap: () async {
                            Navigator.pop(context);
                            await _pickImage(profile, ImageSource.gallery);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildImageOption(
                          icon: Icons.camera_alt_rounded,
                          title: "Kamera",
                          onTap: () async {
                            Navigator.pop(context);
                            await _pickImage(profile, ImageSource.camera);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: pdamSecondary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: pdamPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: pdamPrimary, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: pdamText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog untuk Kelola Nomor Sambungan - FIXED VERSION
  Future<void> _showManageConnectionDialog(
    ProfileService profile,
    AuthService auth,
  ) async {
    final nomorController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                constraints: const BoxConstraints(maxHeight: 650),
                decoration: BoxDecoration(
                  color: pdamCard,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [pdamPrimary, pdamSecondary],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.link, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            "Kelola Nomor Sambungan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Input + Button
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: nomorController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Masukkan Nomor Sambungan...",
                                      filled: true,
                                      fillColor: pdamBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          final nomorText = nomorController.text
                                              .trim();
                                          if (nomorText.isEmpty) {
                                            MySnackBar.show(
                                              context,
                                              message:
                                                  "Nomor sambungan tidak boleh kosong",
                                              type: SnackBarType.error,
                                            );
                                            return;
                                          }

                                          final nomor = int.tryParse(nomorText);
                                          if (nomor == null) {
                                            MySnackBar.show(
                                              context,
                                              message:
                                                  "Nomor sambungan harus berupa angka",
                                              type: SnackBarType.error,
                                            );
                                            return;
                                          }

                                          setState(() => isLoading = true);

                                          try {
                                            final ok = await profile
                                                .registerCustomerConnection(
                                                  nomor,
                                                );
                                            setState(() => isLoading = false);

                                            if (ok) {
                                              nomorController.clear();
                                              MySnackBar.show(
                                                context,
                                                message:
                                                    "Nomor sambungan ditambahkan",
                                                type: SnackBarType.success,
                                              );
                                              setState(() {}); // Refresh list
                                            }
                                          } catch (e) {
                                            setState(() => isLoading = false);
                                            MySnackBar.show(
                                              context,
                                              message: e
                                                  .toString()
                                                  .replaceFirst(
                                                    'Exception: ',
                                                    '',
                                                  ),
                                              type: SnackBarType.error,
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text("Tambah"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: pdamSuccess,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Daftar sambungan terhubung
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: profile.getUserConnections(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Text(
                                    "Belum ada nomor sambungan terhubung",
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }
                                final connections = snapshot.data!;
                                return Column(
                                  children: connections.map((connection) {
                                    final customerData =
                                        connection['customers']
                                            as Map<String, dynamic>;
                                    final connectionNumber =
                                        customerData['connection_number']
                                            .toString();
                                    final customerName =
                                        customerData['nama'] ?? 'N/A';
                                    final rekeningId = connection['id'] as int;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.water_drop_rounded,
                                          color: pdamPrimary,
                                        ),
                                        title: Text("No: $connectionNumber"),
                                        subtitle: Text("Nama: $customerName"),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.link_off,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            // Show confirmation dialog
                                            final confirm =
                                                await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text(
                                                      'Konfirmasi',
                                                    ),
                                                    content: const Text(
                                                      'Yakin ingin menghapus nomor sambungan ini?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          'Batal',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          'Hapus',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ) ??
                                                false;

                                            if (!confirm) return;

                                            try {
                                              final ok = await profile
                                                  .removeUserConnection(
                                                    rekeningId,
                                                  );
                                              if (ok) {
                                                MySnackBar.show(
                                                  context,
                                                  message:
                                                      "Nomor sambungan berhasil dihapus",
                                                  type: SnackBarType.success,
                                                );
                                                setState(() {});
                                              }
                                            } catch (e) {
                                              MySnackBar.show(
                                                context,
                                                message: e
                                                    .toString()
                                                    .replaceFirst(
                                                      'Exception: ',
                                                      '',
                                                    ),
                                                type: SnackBarType.error,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tombol Kembali
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildSecondaryButton(
                        text: "Tutup",
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Dialog untuk Edit Informasi Pelanggan
  Future<void> _showEditInfoDialog(
    ProfileService profile,
    AuthService auth,
  ) async {
    final namaLengkapController = TextEditingController(
      text: auth.username ?? "",
    );
    final nomorHpController = TextEditingController();
    final emailController = TextEditingController(text: auth.email ?? "");
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 650),
            decoration: BoxDecoration(
              color: pdamCard,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan background gradient PDAM
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 24,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [pdamPrimary, pdamSecondary],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Informasi Pelanggan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormField(
                                label: "Nama Lengkap",
                                controller: namaLengkapController,
                                hintText: "Masukkan Nama Lengkap...",
                                icon: Icons.person_outline_rounded,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Nama lengkap wajib diisi"
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: "Nomor HP",
                                controller: nomorHpController,
                                hintText: "Masukkan Nomor HP...",
                                icon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Nomor HP wajib diisi"
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                label: "Email",
                                controller: emailController,
                                hintText: "Masukkan Email...",
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v == null || !v.contains("@")
                                    ? "Email tidak valid"
                                    : null,
                              ),
                              const SizedBox(height: 32),
                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSecondaryButton(
                                      text: "Kembali",
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildPrimaryButton(
                                      text: "Simpan",
                                      isLoading: isLoading,
                                      onPressed: () async {
                                        if (!formKey.currentState!.validate())
                                          return;
                                        setDialogState(() => isLoading = true);

                                        try {
                                          final ok = await profile
                                              .updateProfile(
                                                newName: namaLengkapController
                                                    .text
                                                    .trim(),
                                                newEmail: emailController.text
                                                    .trim(),
                                              );

                                          setDialogState(
                                            () => isLoading = false,
                                          );
                                          if (!mounted) return;

                                          Navigator.pop(context);
                                          if (ok) {
                                            MySnackBar.show(
                                              context,
                                              message:
                                                  "Informasi berhasil diperbarui",
                                              type: SnackBarType.success,
                                            );
                                          }
                                        } catch (e) {
                                          setDialogState(
                                            () => isLoading = false,
                                          );
                                          if (!mounted) return;

                                          Navigator.pop(context);
                                          MySnackBar.show(
                                            context,
                                            message: e.toString().replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                            type: SnackBarType.error,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog untuk Ubah Password 
  Future<void> _showChangePasswordDialog(ProfileService profile) async {
    final kataSandiSekarangController = TextEditingController();
    final kataSandiBaruController = TextEditingController();
    final konfirmasiKataSandiBaruController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 650),
            decoration: BoxDecoration(
              color: pdamCard,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan background gradient PDAM
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 24,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [pdamPrimary, pdamSecondary],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Ubah Kata Sandi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPasswordField(
                                label: "Kata Sandi Sekarang",
                                controller: kataSandiSekarangController,
                                hintText: "Masukkan Kata Sandi Sekarang...",
                                obscureText: obscureCurrentPassword,
                                onToggleVisibility: () {
                                  setDialogState(() {
                                    obscureCurrentPassword =
                                        !obscureCurrentPassword;
                                  });
                                },
                                validator: (v) => v == null || v.isEmpty
                                    ? "Kata sandi sekarang wajib diisi"
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              _buildPasswordField(
                                label: "Kata Sandi Baru",
                                controller: kataSandiBaruController,
                                hintText: "Masukkan Kata Sandi Baru...",
                                obscureText: obscureNewPassword,
                                onToggleVisibility: () {
                                  setDialogState(() {
                                    obscureNewPassword = !obscureNewPassword;
                                  });
                                },
                                validator: (v) => v == null || v.length < 6
                                    ? "Kata sandi baru minimal 6 karakter"
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              _buildPasswordField(
                                label: "Konfirmasi Kata Sandi Baru",
                                controller: konfirmasiKataSandiBaruController,
                                hintText: "Konfirmasi Kata Sandi Baru...",
                                obscureText: obscureConfirmPassword,
                                onToggleVisibility: () {
                                  setDialogState(() {
                                    obscureConfirmPassword =
                                        !obscureConfirmPassword;
                                  });
                                },
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "Konfirmasi kata sandi wajib diisi";
                                  }
                                  if (v != kataSandiBaruController.text) {
                                    return "Konfirmasi kata sandi tidak cocok";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSecondaryButton(
                                      text: "Kembali",
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildPrimaryButton(
                                      text: "Simpan",
                                      isLoading: isLoading,
                                      onPressed: () async {
                                        if (!formKey.currentState!.validate())
                                          return;
                                        setDialogState(() => isLoading = true);

                                        try {
                                          final ok = await profile
                                              .changePassword(
                                                oldPassword:
                                                    kataSandiSekarangController
                                                        .text
                                                        .trim(),
                                                newPassword:
                                                    kataSandiBaruController.text
                                                        .trim(),
                                              );

                                          setDialogState(
                                            () => isLoading = false,
                                          );
                                          if (!mounted) return;

                                          Navigator.pop(context);
                                          if (ok) {
                                            MySnackBar.show(
                                              context,
                                              message:
                                                  "Password berhasil diubah",
                                              type: SnackBarType.success,
                                            );
                                          }
                                        } catch (e) {
                                          setDialogState(
                                            () => isLoading = false,
                                          );
                                          if (!mounted) return;

                                          Navigator.pop(context);
                                          MySnackBar.show(
                                            context,
                                            message: e.toString().replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                            type: SnackBarType.error,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //informasi kantor
  Future<void> _showOfficeInfoDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              color: pdamCard,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan gradient PDAM
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [pdamPrimary, pdamSecondary],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Informasi Kantor",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Isi informasi kantor
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoItem(
                          icon: Icons.phone,
                          title: "Telepon",
                          value: "(0542) 7218831 / 7218832",
                        ),
                        const Divider(),
                        _buildInfoItem(
                          icon: Icons.email,
                          title: "Email",
                          value: "humas@tirtamanuntung.co.id",
                        ),
                        const Divider(),
                        _buildInfoItem(
                          icon: Icons.location_on,
                          title: "Lokasi",
                          value:
                              "Graha Tirta Building\nJl. Ruhui Rahayu I,\nBalikpapan, Kalimantan Timur",
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildPrimaryButton(
                            text: "Tutup",
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: pdamPrimary,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: pdamText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: pdamText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method untuk membuat form field 
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: pdamText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: pdamText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: pdamBackground,
            prefixIcon: icon != null
                ? Icon(icon, color: pdamPrimary.withOpacity(0.7), size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: pdamPrimary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method untuk membuat password field dengan toggle visibility
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: pdamText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: pdamText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: pdamBackground,
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: pdamPrimary.withOpacity(0.7),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: pdamPrimary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Helper untuk tombol utama
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [pdamPrimary, pdamSecondary]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: pdamPrimary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // Helper untuk tombol sekunder
  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: pdamText,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _pickImage(ProfileService profile, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
        final ok = await profile.updateProfilePhoto(File(picked.path));
        if (ok) {
          MySnackBar.show(
            context,
            message: "Foto profil berhasil diperbarui",
            type: SnackBarType.success,
          );
        }
      }
    } catch (e) {
      MySnackBar.show(
        context,
        message: "Gagal upload foto: $e",
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, ProfileService>(
      builder: (context, auth, profile, child) {
        return Scaffold(
          backgroundColor: pdamBackground,
          body: Column(
            children: [
              _buildHeader(auth, profile),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    FutureBuilder<bool>(
                      future: auth.hasValidConnectionNumber,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                pdamPrimary,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError || !(snapshot.data ?? false)) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextPoppins(
                                    text:
                                        "Segera verifikasi nomor sambungan Anda untuk dapat menggunakan layanan kami!",
                                    fontSize: 13,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const TextPoppins(
                      text: "Pengaturan Akun",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: pdamText,
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _menuTile(
                        icon: Icons.person_outline_rounded,
                        title: "Informasi Pelanggan",
                        subtitle: "Perbarui data pribadi Anda",
                        onTap: () => _showEditInfoDialog(profile, auth),
                      ),
                      _menuTile(
                        icon: Icons.link,
                        title: "Nomor Sambungan",
                        subtitle: "Kelola nomor sambungan",
                        onTap: () => _showManageConnectionDialog(profile, auth),
                      ),
                      _menuTile(
                        icon: Icons.lock_outline_rounded,
                        title: "Kata Sandi",
                        subtitle: "Ubah kata sandi akun",
                        onTap: () => _showChangePasswordDialog(profile),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    const TextPoppins(
                      text: "Lainnya",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: pdamText,
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _menuTile(
                        icon: Icons.phone_outlined,
                        title: "Hubungi Kami",
                        subtitle: "Customer service PDAM",
                        onTap: () => _showOfficeInfoDialog(context),
                      ),
                      _menuTile(
                        icon: Icons.exit_to_app_rounded,
                        title: "Keluar",
                        subtitle: "Keluar dari akun",
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              title: const TextPoppins(
                                text: 'Logout',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              content: const TextPoppins(
                                text: 'Apakah Anda yakin ingin keluar?',
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const TextPoppins(
                                    text: 'Batal',
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      await context
                                          .read<AuthService>()
                                          .signOut();
                                      if (mounted) {
                                        _signOutTrasisi();
                                      }
                                    } catch (e) {
                                      debugPrint("Logout error: $e");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const TextPoppins(
                                    text: 'Logout',
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        color: Colors.red,
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AuthService auth, ProfileService profile) {
    final imageUrl = profile.authService.photoProfile;
    return Stack(
      children: [
        // Background Image with Gradient Overlay
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/kantorpdam.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        // Back Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, "/userHome"),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: pdamPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Profil Saya",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: pdamPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 40), // Balance the back button
              ],
            ),
          ),
        ),
        // Profile Section
        Container(
          margin: const EdgeInsets.only(top: 120), // agak naik biar pas
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Foto Profil
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (imageUrl != null
                                  ? NetworkImage(imageUrl) as ImageProvider
                                  : const AssetImage(
                                      "assets/profile-default.jpg",
                                    )),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _showImageSourceDialog(profile),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [pdamPrimary, pdamSecondary],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Nama
                  TextPoppins(
                    text: auth.username ?? "Guest User",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: pdamText,
                  ),
                  const SizedBox(height: 4),
                  // Email
                  TextPoppins(
                    text: auth.email ?? "-",
                    fontSize: 14,
                    color: Colors.grey[600]!,
                  ),
                  const SizedBox(height: 12),
                  // Status Verifikasi
                  FutureBuilder<bool>(
                    future: auth.hasValidConnectionNumber,
                    builder: (context, snapshot) {
                      final hasConnection = snapshot.data ?? false;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: hasConnection
                              ? pdamSuccess.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasConnection
                                  ? Icons.verified_rounded
                                  : Icons.warning_rounded,
                              size: 14,
                              color: hasConnection
                                  ? pdamSuccess
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            TextPoppins(
                              text: hasConnection
                                  ? "Nomor sambungan terverifikasi"
                                  : "Nomor sambungan belum terverifikasi",
                              fontSize: 11,
                              color: hasConnection
                                  ? pdamSuccess
                                  : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = pdamText,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color == pdamText
                      ? pdamPrimary.withOpacity(0.1)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color == pdamText ? pdamPrimary : color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextPoppins(
                      text: title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    const SizedBox(height: 2),
                    TextPoppins(
                      text: subtitle,
                      fontSize: 12,
                      color: Colors.grey[600]!,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

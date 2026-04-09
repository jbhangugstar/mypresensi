import 'package:flutter/material.dart';
import 'package:mypresensi/api/auth/profile_user.dart';
import '../model/profile_model.dart';
import '../api/auth/login_user.dart';
import 'login_screen.dart';
import '../main.dart';
import '../database/preference.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameC = TextEditingController();
  final emailC = TextEditingController();

  bool isLoading = true;
  bool isUpdate = false;

  ProfileModel? profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ================= LOAD PROFILE =================
  void loadProfile() async {
    try {
      final data = await ProfileApi.getProfile();

      setState(() {
        profile = data;
        nameC.text = data.name;
        emailC.text = data.email;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ================= UPDATE =================
  void updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUpdate = true);

    final model = ProfileModel(
      id: profile!.id,
      name: nameC.text,
      email: emailC.text,
    );

    final success = await ProfileApi.updateProfile(model);

    setState(() => isUpdate = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Berhasil update" : "Gagal update")),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: cs.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // ================= HEADER =================
                      Text(
                        "Profil Saya",
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ================= FOTO =================
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: cs.primaryContainer,
                        backgroundImage: profile!.photo != null
                            ? NetworkImage(profile!.photo!)
                            : null,
                        child: profile!.photo == null
                            ? Icon(
                                Icons.person,
                                size: 56,
                                color: cs.onPrimaryContainer,
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile?.name ?? '',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        profile?.email ?? '',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ================= DARK MODE =================
                      Card(
                        color: cs.surfaceContainerLow,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: themeNotifier,
                          builder: (context, isDark, child) {
                            return SwitchListTile(
                              title: Text(
                                "Mode Gelap",
                                style: tt.bodyLarge?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                isDark ? "Aktif" : "Nonaktif",
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              secondary: Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                color: cs.primary,
                              ),
                              value: isDark,
                              onChanged: (val) {
                                themeNotifier.value = val;
                                PreferenceHandler().storingTheme(val);
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= CARD FORM =================
                      Card(
                        color: cs.surfaceContainerLow,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Edit Profil",
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // NAME
                              TextFormField(
                                controller: nameC,
                                validator: (v) =>
                                    v!.isEmpty ? "Nama wajib diisi" : null,
                                decoration: InputDecoration(
                                  labelText: "Nama",
                                  prefixIcon: const Icon(Icons.person_outlined),
                                  fillColor: cs.surfaceContainerHighest,
                                ),
                              ),

                              const SizedBox(height: 14),

                              // EMAIL
                              TextFormField(
                                controller: emailC,
                                validator: (v) =>
                                    v!.isEmpty ? "Email wajib diisi" : null,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  fillColor: cs.surfaceContainerHighest,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // UPDATE BUTTON
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: isUpdate ? null : updateProfile,
                                  icon: isUpdate
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save_outlined),
                                  label: const Text("Simpan Perubahan"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= LOGOUT =================
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Keluar"),
                                content: const Text("Yakin ingin logout?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Batal"),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: cs.error,
                                    ),
                                    child: const Text("Logout"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await LoginUser.logout();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                          icon: Icon(Icons.logout, color: cs.error),
                          label: Text(
                            "Logout",
                            style: TextStyle(color: cs.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

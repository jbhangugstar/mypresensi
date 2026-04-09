import 'package:flutter/material.dart';
import 'package:mypresensi/extension/navigator.dart';
import 'package:mypresensi/view/dashboard_screen.dart';
import 'package:mypresensi/view/register_screen.dart';
import '../api/auth/login_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email & Password wajib diisi")),
      );
      return;
    }

    if (!email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format email tidak valid")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 6 karakter")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await LoginUser.login(email: email, password: password);

    setState(() => isLoading = false);

    if (result != null) {
      context.pushAndRemoveAll(DashboardScreen());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login gagal")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, cs.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ================= LOGO =================
                Image.asset(
                  "assets/images/logo _MyPresensi.png",
                  height: 160,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),

                // ================= CARD LOGIN =================
                Card(
                  color: cs.surface,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Selamat Datang",
                          textAlign: TextAlign.center,
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Masuk ke akun Anda",
                          textAlign: TextAlign.center,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ================= EMAIL =================
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            fillColor: cs.surfaceContainerHighest,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ================= PASSWORD =================
                        TextField(
                          controller: passwordController,
                          obscureText: isPasswordHidden,
                          decoration: InputDecoration(
                            labelText: "Kata Sandi",
                            prefixIcon: const Icon(Icons.lock_outlined),
                            fillColor: cs.surfaceContainerHighest,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordHidden
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordHidden = !isPasswordHidden;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ================= BUTTON LOGIN =================
                        FilledButton(
                          onPressed: isLoading ? null : handleLogin,
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Masuk",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),

                        const SizedBox(height: 16),

                        // ================= REGISTER =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Belum punya akun? ",
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Daftar",
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // ================= FORGOT PASSWORD =================
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Fitur lupa password belum tersedia",
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Lupa Kata Sandi?",
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

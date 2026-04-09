import 'package:flutter/material.dart';
import 'package:mypresensi/api/auth/register_user.dart';
import 'package:mypresensi/extension/navigator.dart';
import 'package:mypresensi/view/login_screen.dart';
import '../model/training_model.dart';
import '../model/batch_model.dart';
import '../model/register_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  String selectedGender = 'L';

  List<TrainingModel> trainings = [];
  List<BatchModel> batches = [];

  TrainingModel? selectedTraining;
  BatchModel? selectedBatch;

  bool isLoading = true;
  bool isSubmit = false;
  bool isLoadingBatch = false;
  bool isPasswordHidden = true;

  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  void loadData() async {
    try {
      final t = await RegisterApi.getTrainings();
      setState(() {
        trainings = t;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> loadBatch(int trainingId) async {
    setState(() {
      isLoadingBatch = true;
      batches = [];
      selectedBatch = null;
    });

    try {
      final b = await RegisterApi.getBatchesByTraining(trainingId);
      setState(() {
        batches = b;
        isLoadingBatch = false;
      });
    } catch (e) {
      setState(() {
        isLoadingBatch = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal load batch: $e")),
      );
    }
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTraining == null || selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih training & batch")),
      );
      return;
    }

    setState(() => isSubmit = true);

    final model = RegisterModel(
      name: nameC.text.trim(),
      email: emailC.text.trim(),
      password: passwordC.text.trim(),
      gender: selectedGender,
      trainingId: selectedTraining!.id,
      batchId: selectedBatch!.id,
    );

    final success = await RegisterApi.register(model);

    setState(() => isSubmit = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Register berhasil")),
      );

      _formKey.currentState!.reset();
      nameC.clear();
      emailC.clear();
      passwordC.clear();

      setState(() {
        selectedGender = 'L';
        selectedTraining = null;
        selectedBatch = null;
        batches = [];
      });

      context.pushAndRemoveAll(LoginScreen());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Register gagal, cek console debug"),
        ),
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
          child: isLoading
              ? CircularProgressIndicator(color: cs.onPrimary)
              : errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        errorMessage,
                        style: tt.bodyLarge?.copyWith(color: cs.error),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ================= LOGO =================
                          Image.asset(
                            "assets/images/logo _MyPresensi.png",
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),

                          // ================= CARD REGISTER =================
                          Card(
                            color: cs.surface,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      "Buat Akun",
                                      textAlign: TextAlign.center,
                                      style: tt.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    _buildInput(nameC, "Nama", cs, prefixIcon: Icons.person_outlined),
                                    const SizedBox(height: 14),

                                    _buildInput(emailC, "Email", cs,
                                        keyboardType: TextInputType.emailAddress,
                                        prefixIcon: Icons.email_outlined),
                                    const SizedBox(height: 14),

                                    _buildInput(passwordC, "Kata Sandi", cs,
                                        isPassword: true,
                                        prefixIcon: Icons.lock_outlined),
                                    const SizedBox(height: 14),

                                    _buildDropdownGender(cs),
                                    const SizedBox(height: 14),

                                    _buildDropdownTraining(cs),
                                    const SizedBox(height: 14),

                                    _buildDropdownBatch(cs),
                                    const SizedBox(height: 24),

                                    FilledButton(
                                      onPressed: isSubmit ? null : submit,
                                      child: isSubmit
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              "Daftar",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Sudah punya akun? ",
                                          style: tt.bodyMedium?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const LoginScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Login",
                                            style: tt.bodyMedium?.copyWith(
                                              color: cs.primary,
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
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController c,
    String hint,
    ColorScheme cs, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      obscureText: isPassword ? isPasswordHidden : false,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return "$hint wajib diisi";
        if (hint == "Email" && !v.contains("@")) return "Email tidak valid";
        if (hint == "Kata Sandi" && v.length < 6) return "Password minimal 6 karakter";
        return null;
      },
      decoration: InputDecoration(
        labelText: hint,
        fillColor: cs.surfaceContainerHighest,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildDropdownGender(ColorScheme cs) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(
        labelText: "Jenis Kelamin",
        fillColor: cs.surfaceContainerHighest,
        prefixIcon: const Icon(Icons.wc_outlined),
      ),
      isExpanded: true,
      items: const [
        DropdownMenuItem(value: 'L', child: Text("Laki-laki")),
        DropdownMenuItem(value: 'P', child: Text("Perempuan")),
      ],
      onChanged: (val) {
        if (val == null) return;
        setState(() => selectedGender = val);
      },
    );
  }

  Widget _buildDropdownTraining(ColorScheme cs) {
    return DropdownButtonFormField<TrainingModel>(
      value: selectedTraining,
      hint: const Text("Pilih Training"),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: "Training",
        fillColor: cs.surfaceContainerHighest,
        prefixIcon: const Icon(Icons.school_outlined),
      ),
      items: trainings.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e.title, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (val) async {
        if (val == null) return;
        setState(() {
          selectedTraining = val;
        });
        await loadBatch(val.id);
      },
      validator: (value) => value == null ? "Training wajib dipilih" : null,
    );
  }

  Widget _buildDropdownBatch(ColorScheme cs) {
    return DropdownButtonFormField<BatchModel>(
      value: selectedBatch,
      hint: isLoadingBatch
          ? const Text("Loading batch...")
          : const Text("Pilih Batch"),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: "Batch",
        fillColor: cs.surfaceContainerHighest,
        prefixIcon: const Icon(Icons.group_outlined),
      ),
      items: batches.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e.name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: selectedTraining == null
          ? null
          : (val) {
              if (val == null) return;
              setState(() {
                selectedBatch = val;
              });
            },
      validator: (value) => value == null ? "Batch wajib dipilih" : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mypresensi/api/register_user.dart';
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

  String selectedGender = 'L'; // ✅ API maunya L / P

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

  // ================= LOAD TRAINING =================
  void loadData() async {
    try {
      print("========== LOAD TRAINING DEBUG ==========");
      print("Mulai ambil data training...");

      final t = await RegisterApi.getTrainings();

      print("Jumlah training: ${t.length}");
      print("=========================================");

      setState(() {
        trainings = t;
        isLoading = false;
      });
    } catch (e) {
      print("LOAD TRAINING ERROR: $e");

      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  // ================= LOAD BATCH =================
  Future<void> loadBatch(int trainingId) async {
    setState(() {
      isLoadingBatch = true;
      batches = [];
      selectedBatch = null;
    });

    try {
      print("========== LOAD BATCH DEBUG ==========");
      print("Training ID dipilih: $trainingId");
      print("Ambil batch berdasarkan training...");

      final b = await RegisterApi.getBatchesByTraining(trainingId);

      print("Jumlah batch: ${b.length}");
      print("======================================");

      setState(() {
        batches = b;
        isLoadingBatch = false;
      });
    } catch (e) {
      print("LOAD BATCH ERROR: $e");

      setState(() {
        isLoadingBatch = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal load batch: $e")));
    }
  }

  // ================= SUBMIT REGISTER =================
  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTraining == null || selectedBatch == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pilih training & batch")));
      return;
    }

    setState(() => isSubmit = true);

    final model = RegisterModel(
      name: nameC.text.trim(),
      email: emailC.text.trim(),
      password: passwordC.text.trim(),
      gender: selectedGender, // L / P
      trainingId: selectedTraining!.id,
      batchId: selectedBatch!.id,
    );

    print("========== REGISTER SCREEN DEBUG ==========");
    print("Nama         : ${nameC.text.trim()}");
    print("Email        : ${emailC.text.trim()}");
    print("Password     : ${passwordC.text.trim()}");
    print("Gender       : $selectedGender");
    print("Training ID  : ${selectedTraining!.id}");
    print("Training     : ${selectedTraining!.title}");
    print("Batch ID     : ${selectedBatch!.id}");
    print("Batch        : ${selectedBatch!.name}");
    print("JSON BODY    : ${model.toJson()}");
    print("===========================================");

    final success = await RegisterApi.register(model);

    setState(() => isSubmit = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Register berhasil")));

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Register gagal, cek console debug"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.grey.shade900,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : errorMessage.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Register Account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          buildInput(nameC, "Nama"),
                          const SizedBox(height: 12),

                          buildInput(
                            emailC,
                            "Email",
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          buildInput(passwordC, "Kata Sandi", isPassword: true),
                          const SizedBox(height: 12),

                          buildDropdownGender(),
                          const SizedBox(height: 12),

                          buildDropdownTraining(),
                          const SizedBox(height: 12),

                          buildDropdownBatch(),
                          const SizedBox(height: 24),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: isSubmit ? null : submit,
                            child: isSubmit
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Daftar",
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // ================= INPUT =================
  Widget buildInput(
    TextEditingController c,
    String hint, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      obscureText: isPassword ? isPasswordHidden : false,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return "$hint wajib diisi";
        }

        if (hint == "Email" && !v.contains("@")) {
          return "Email tidak valid";
        }

        if (hint == "Kata Sandi" && v.length < 6) {
          return "Password minimal 6 karakter";
        }

        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================= DROPDOWN GENDER =================
  Widget buildDropdownGender() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: inputStyle(),
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

  // ================= DROPDOWN TRAINING =================
  Widget buildDropdownTraining() {
    return DropdownButtonFormField<TrainingModel>(
      value: selectedTraining,
      hint: const Text("Pilih Training"),
      isExpanded: true,
      decoration: inputStyle(),
      items: trainings.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e.title, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (val) async {
        if (val == null) return;

        print("Training dipilih: ${val.title} (ID: ${val.id})");

        setState(() {
          selectedTraining = val;
        });

        await loadBatch(val.id);
      },
      validator: (value) => value == null ? "Training wajib dipilih" : null,
    );
  }

  // ================= DROPDOWN BATCH =================
  Widget buildDropdownBatch() {
    return DropdownButtonFormField<BatchModel>(
      value: selectedBatch,
      hint: isLoadingBatch
          ? const Text("Loading batch...")
          : const Text("Pilih Batch"),
      isExpanded: true,
      decoration: inputStyle(),
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

              print("Batch dipilih: ${val.name} (ID: ${val.id})");

              setState(() {
                selectedBatch = val;
              });
            },
      validator: (value) => value == null ? "Batch wajib dipilih" : null,
    );
  }

  // ================= STYLE =================
  InputDecoration inputStyle() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

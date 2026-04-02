import 'package:flutter/material.dart';
import '../model/get_user_model.dart';
import '../api/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final GetUserData user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameC;
  late TextEditingController emailC;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.user.name);
    emailC = TextEditingController(text: widget.user.email);
  }

  Future<void> updateUser() async {
    setState(() => isLoading = true);

    try {
      final result = await AuthService.updateProfile(
        name: nameC.text,
        email: emailC.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Update berhasil')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update gagal: $e')));
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    super.dispose();
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTextField('Nama', nameC),
            buildTextField('Email', emailC),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading ? null : updateUser,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

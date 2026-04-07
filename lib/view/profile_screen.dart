import 'package:flutter/material.dart';
import 'package:mypresensi/api/profile_user.dart';
import '../model/profile_model.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // FOTO
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profile!.photo != null
                          ? NetworkImage(profile!.photo!)
                          : null,
                      child: profile!.photo == null
                          ? Icon(Icons.person, size: 50)
                          : null,
                    ),

                    SizedBox(height: 20),

                    // NAME
                    TextFormField(
                      controller: nameC,
                      validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                      decoration: InputDecoration(
                        labelText: "Nama",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 15),

                    // EMAIL
                    TextFormField(
                      controller: emailC,
                      validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: isUpdate ? null : updateProfile,
                      child: isUpdate
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Update Profile"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

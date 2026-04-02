import 'package:flutter/material.dart';
import '../model/get_user_model.dart';
import '../api/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<GetUserModel> futureProfile;

  @override
  void initState() {
    super.initState();
    futureProfile = AuthService.getProfile();
  }

  void refreshProfile() {
    setState(() {
      futureProfile = AuthService.getProfile();
    });
  }

  Future<void> logout() async {
    await AuthService.logout();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Widget buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.purple.shade50,
            child: Icon(icon, color: Colors.purple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color backgroundColor = Colors.purple,
    Color textColor = Colors.white,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor),
        label: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FB),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: FutureBuilder<GetUserModel>(
        future: futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final user = snapshot.data?.data;

          if (user == null) {
            return const Center(child: Text('Data user tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// Avatar
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.purple.shade100,
                  child: Text(
                    (user.name != null && user.name!.isNotEmpty)
                        ? user.name![0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// Nama besar
                Text(
                  user.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                /// Email kecil
                Text(
                  user.email ?? '-',
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                /// Detail user
                buildInfoTile(
                  icon: Icons.person,
                  title: 'Nama Lengkap',
                  value: user.name ?? '-',
                ),

                buildInfoTile(
                  icon: Icons.email,
                  title: 'Email',
                  value: user.email ?? '-',
                ),

                const SizedBox(height: 24),

                /// Tombol edit
                buildActionButton(
                  text: 'Edit Profile',
                  icon: Icons.edit,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      '/edit_profile',
                      arguments: user,
                    );
                    refreshProfile();
                  },
                ),

                const SizedBox(height: 14),

                /// Tombol logout
                buildActionButton(
                  text: 'Logout',
                  icon: Icons.logout,
                  backgroundColor: Colors.white,
                  textColor: Colors.red,
                  onTap: logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

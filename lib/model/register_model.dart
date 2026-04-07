class RegisterModel {
  final String name;
  final String email;
  final String password;
  final String gender;
  final int trainingId;
  final int batchId;

  RegisterModel({
    required this.name,
    required this.email,
    required this.password,
    required this.gender,
    required this.trainingId,
    required this.batchId,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "jenis_kelamin": gender, // ✅ FIX DI SINI
      "training_id": trainingId,
      "batch_id": batchId,
    };
  }
}

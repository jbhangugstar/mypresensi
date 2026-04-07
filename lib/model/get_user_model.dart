class GetUserModel {
  final int id;
  final String name;
  final String email;
  final String? gender;
  final int? trainingId;
  final int? batchId;

  GetUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    this.trainingId,
    this.batchId,
  });

  factory GetUserModel.fromJson(Map<String, dynamic> json) {
    return GetUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['jenis_kelamin']?.toString(),
      trainingId: json['training_id'],
      batchId: json['batch_id'],
    );
  }
}

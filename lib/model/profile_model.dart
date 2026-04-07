class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String? photo;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "email": email};
  }
}

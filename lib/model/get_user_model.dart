class GetUserModel {
  final String? message;
  final GetUserData? data;

  GetUserModel({this.message, this.data});

  factory GetUserModel.fromJson(Map<String, dynamic> json) => GetUserModel(
    message: json['message'] as String?,
    data: json['data'] == null
        ? null
        : GetUserData.fromJson(json['data'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {'message': message, 'data': data?.toJson()};
}

class GetUserData {
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  GetUserData({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory GetUserData.fromJson(Map<String, dynamic> json) => GetUserData(
    id: json['id'] as int?,
    name: json['name'] as String?,
    email: json['email'] as String?,
    emailVerifiedAt: json['email_verified_at'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'email_verified_at': emailVerifiedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

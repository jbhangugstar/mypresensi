class AbsenResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  AbsenResponseModel({required this.success, required this.message, this.data});

  factory AbsenResponseModel.fromJson(Map<String, dynamic> json) {
    return AbsenResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Tidak ada pesan',
      data: json['data'],
    );
  }
}

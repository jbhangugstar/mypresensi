class TrainingModel {
  final int id;
  final String title;

  TrainingModel({required this.id, required this.title});

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(id: json['id'] ?? 0, title: json['title'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "title": title};
  }
}

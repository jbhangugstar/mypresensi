class BatchModel {
  final int id;
  final String name;

  BatchModel({required this.id, required this.name});

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    final batchKe = json['batch_ke']?.toString();
    final rawName = json['name']?.toString();

    return BatchModel(
      id: json['id'] ?? 0,
      name: batchKe != null && batchKe.isNotEmpty
          ? "Batch $batchKe"
          : rawName ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }

  @override
  String toString() => name;
}

class SourceModel {
  final String id;
  final String name;
  final String type;
  final double startingAmount;
  final int createdAt;

  SourceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.startingAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'startingAmount': startingAmount,
      'createdAt': createdAt,
    };
  }

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      startingAmount: (json['startingAmount'] as num).toDouble(),
      createdAt: json['createdAt'] as int,
    );
  }
}

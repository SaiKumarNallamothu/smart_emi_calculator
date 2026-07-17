import 'dart:convert';

class CalculationModel {
  final int? id;
  final String type;
  final String title;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> outputs;
  final DateTime createdAt;
  final bool isFavorite;

  CalculationModel({
    this.id,
    required this.type,
    required this.title,
    required this.inputs,
    required this.outputs,
    required this.createdAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'title': title,
      'inputs': jsonEncode(inputs),
      'outputs': jsonEncode(outputs),
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory CalculationModel.fromMap(Map<String, dynamic> map) {
    return CalculationModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      title: map['title'] as String,
      inputs: jsonDecode(map['inputs'] as String) as Map<String, dynamic>,
      outputs: jsonDecode(map['outputs'] as String) as Map<String, dynamic>,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isFavorite: (map['isFavorite'] as int) == 1,
    );
  }

  CalculationModel copyWith({
    int? id,
    String? type,
    String? title,
    Map<String, dynamic>? inputs,
    Map<String, dynamic>? outputs,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return CalculationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

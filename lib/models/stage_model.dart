enum StageCategory { dobleG, embudo }

enum StageResultState {
  unobserved, // Sin observar
  yes,        // Sí
  no;         // No

  String get label {
    switch (this) {
      case StageResultState.unobserved:
        return 'Sin observar';
      case StageResultState.yes:
        return 'Sí';
      case StageResultState.no:
        return 'No';
    }
  }

  StageResultState get next {
    switch (this) {
      case StageResultState.unobserved:
        return StageResultState.yes;
      case StageResultState.yes:
        return StageResultState.no;
      case StageResultState.no:
        return StageResultState.unobserved;
    }
  }
}

class StageModel {
  final String id;
  final StageCategory category;
  final String title;
  final String description;
  final int orderIndex;
  final bool isKeyConversion; // true for Compra
  final int? targetSeconds;

  StageModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.orderIndex,
    this.isKeyConversion = false,
    this.targetSeconds,
  });

  String get categoryLabel => category == StageCategory.dobleG ? 'DOBLE G' : 'EMBUDO';

  StageModel copyWith({
    String? id,
    StageCategory? category,
    String? title,
    String? description,
    int? orderIndex,
    bool? isKeyConversion,
    int? targetSeconds,
  }) {
    return StageModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      isKeyConversion: isKeyConversion ?? this.isKeyConversion,
      targetSeconds: targetSeconds ?? this.targetSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'isKeyConversion': isKeyConversion,
      'targetSeconds': targetSeconds,
    };
  }

  factory StageModel.fromMap(Map<String, dynamic> map) {
    return StageModel(
      id: map['id'] as String,
      category: map['category'] == 'dobleG' ? StageCategory.dobleG : StageCategory.embudo,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      orderIndex: map['orderIndex'] as int? ?? 0,
      isKeyConversion: map['isKeyConversion'] as bool? ?? false,
      targetSeconds: map['targetSeconds'] as int?,
    );
  }
}

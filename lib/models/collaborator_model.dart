class CollaboratorModel {
  final String id;
  final String code; // e.g. "V1", "V2", "V3"
  final String fullName;
  final String branchId;
  final String branchName;
  final String position; // e.g. "Vendedor Piso", "Cajero / Asesor"
  final bool isActive;

  CollaboratorModel({
    required this.id,
    required this.code,
    required this.fullName,
    required this.branchId,
    required this.branchName,
    this.position = 'Asesor de Calzado',
    this.isActive = true,
  });

  CollaboratorModel copyWith({
    String? id,
    String? code,
    String? fullName,
    String? branchId,
    String? branchName,
    String? position,
    bool? isActive,
  }) {
    return CollaboratorModel(
      id: id ?? this.id,
      code: code ?? this.code,
      fullName: fullName ?? this.fullName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'fullName': fullName,
      'branchId': branchId,
      'branchName': branchName,
      'position': position,
      'isActive': isActive,
    };
  }

  factory CollaboratorModel.fromMap(Map<String, dynamic> map) {
    return CollaboratorModel(
      id: map['id'] as String,
      code: map['code'] as String,
      fullName: map['fullName'] as String,
      branchId: map['branchId'] as String,
      branchName: map['branchName'] as String? ?? '',
      position: map['position'] as String? ?? 'Asesor de Calzado',
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

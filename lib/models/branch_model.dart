class BranchModel {
  final String id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String managerName;
  final String phone;
  final bool isActive;

  BranchModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.managerName,
    required this.phone,
    this.isActive = true,
  });

  BranchModel copyWith({
    String? id,
    String? name,
    String? code,
    String? address,
    String? city,
    String? managerName,
    String? phone,
    bool? isActive,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      city: city ?? this.city,
      managerName: managerName ?? this.managerName,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'city': city,
      'managerName': managerName,
      'phone': phone,
      'isActive': isActive,
    };
  }

  factory BranchModel.fromMap(Map<String, dynamic> map) {
    return BranchModel(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      managerName: map['managerName'] as String,
      phone: map['phone'] as String,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

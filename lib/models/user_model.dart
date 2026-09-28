enum UserRole { admin, rh }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? branchId;
  final String? branchName;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.branchId,
    this.branchName,
    this.isActive = true,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isRH => role == UserRole.rh;

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.rh:
        return 'Recursos Humanos (RH)';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'branchId': branchId,
      'branchName': branchName,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.rh,
      branchId: map['branchId'] as String?,
      branchName: map['branchName'] as String?,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

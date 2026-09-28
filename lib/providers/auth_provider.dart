import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/database_repository.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseRepository _repo;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._repo) {
    _initAutoLogin();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isRH => _currentUser?.isRH ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _initAutoLogin() async {
    // Iniciar con RH por defecto para permitir acceso directo a las visitas de auditoría
    final users = await _repo.getUsers();
    if (users.isNotEmpty) {
      final rhUser = users.firstWhere((u) => u.isRH, orElse: () => users.first);
      _currentUser = rhUser;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final users = await _repo.getUsers();
      final user = users.firstWhere(
        (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase(),
        orElse: () => throw Exception('Usuario no encontrado'),
      );

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Credenciales no válidas. Verifica correo o selecciona acceso rápido.';
      notifyListeners();
      return false;
    }
  }

  Future<void> loginAsAdmin() async {
    final users = await _repo.getUsers();
    final admin = users.firstWhere(
      (u) => u.isAdmin,
      orElse: () => UserModel(
        id: 'user_admin_01',
        name: 'Lic. Fernando García',
        email: 'admin@lagarcia.com',
        role: UserRole.admin,
      ),
    );
    _currentUser = admin;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loginAsRH() async {
    final users = await _repo.getUsers();
    final rh = users.firstWhere(
      (u) => u.isRH,
      orElse: () => UserModel(
        id: 'user_rh_01',
        name: 'Mtra. Carolina Ruiz',
        email: 'rh@lagarcia.com',
        role: UserRole.rh,
      ),
    );
    _currentUser = rh;
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

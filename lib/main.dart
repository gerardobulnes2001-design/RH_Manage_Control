import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/visit_provider.dart';
import 'repositories/database_repository.dart';
import 'repositories/local_database_repository.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Repositorio de base de datos local (persistente con SharedPreferences y datos iniciales)
  final DatabaseRepository databaseRepository = LocalDatabaseRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseRepository>.value(value: databaseRepository),
        ChangeNotifierProvider(create: (_) => AuthProvider(databaseRepository)),
        ChangeNotifierProvider(create: (_) => AdminProvider(databaseRepository)),
        ChangeNotifierProvider(create: (_) => VisitProvider(databaseRepository)),
      ],
      child: const LaGarciaRHApp(),
    ),
  );
}

class LaGarciaRHApp extends StatelessWidget {
  const LaGarciaRHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La García Zapatería - RH & Control',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}

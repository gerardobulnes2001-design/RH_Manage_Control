import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/visit_provider.dart';
import 'repositories/database_repository.dart';
import 'repositories/supabase_database_repository.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar cliente Supabase
  await SupabaseConfig.initializeClient();

  // Repositorio de base de datos Supabase (con sincronización y persistencia)
  final DatabaseRepository databaseRepository = SupabaseDatabaseRepository();

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

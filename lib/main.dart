import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'services/preferences_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Inicializamos los bindings de Flutter antes de cargar SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Verificamos si existe una sesión activa guardada
  final UserModel? userSession = await PreferencesService.getUserSession();

  runApp(MiAplicacionInventario(initialUser: userSession));
}

class MiAplicacionInventario extends StatelessWidget {
  final UserModel? initialUser;

  const MiAplicacionInventario({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Inventario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
          primary: const Color(0xFF2D6A4F),
          secondary: const Color(0xFF52B788),
          surface: const Color(0xFFF4F9F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFEFEFEF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D6A4F),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: initialUser != null ? HomeScreen(user: initialUser!) : const LoginScreen(),
    );
  }
}
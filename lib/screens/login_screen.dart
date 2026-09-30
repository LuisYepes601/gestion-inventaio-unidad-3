import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/db_helper.dart';
import '../services/preferences_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

// Pantalla de inicio de sesión con imagen de fondo limpia
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // Método para validar el ingreso contra la base de datos local SQLite
  void _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      final UserModel? user = await DatabaseHelper.instance.loginUser(email, password);

      if (!mounted) return;

      if (user != null) {
        // Guardamos la sesión activa en SharedPreferences
        await PreferencesService.saveUserSession(user);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido de nuevo, ${user.fullName}!'),
            backgroundColor: const Color(0xFF1B4332),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Redirección al Home pasando el usuario logueado
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo o contraseña incorrectos. Verifica tus datos.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Imagen de fondo que cubre toda la pantalla
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=1000&auto=format&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Capa de degradado oscuro sobre la imagen para resaltar los textos
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.75),
                  const Color(0xFF1B4332).withOpacity(0.65),
                  Colors.black.withOpacity(0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 3. Contenido principal y tarjeta del formulario
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título principal limpio sin ícono de caja
                  const Text(
                    'SISTEMA DE BODEGA',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Gestión e Inventarios',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),

                  // Tarjeta del formulario con transparencia
                  Card(
                    color: Colors.white.withOpacity(0.92),
                    elevation: 10,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B4332),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Correo Electrónico',
                                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2D6A4F)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (v) => v == null || !v.contains('@') ? 'Ingresa tu correo registrado' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2D6A4F)),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Ingresa tu clave' : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2D6A4F),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 4,
                                ),
                                onPressed: _login,
                                child: const Text(
                                  'INGRESAR AL INVENTARIO',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('¿No tienes cuenta? ', style: TextStyle(color: Colors.black87)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'Regístrate aquí',
                                    style: TextStyle(
                                      color: Color(0xFF2D6A4F),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
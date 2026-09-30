import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/db_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'Administrador';
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailCtrl.text.trim();

      try {
        final exists = await DatabaseHelper.instance.checkEmailExists(email);
        if (exists) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('El correo ya se encuentra registrado')),
                ],
              ),
              backgroundColor: Colors.orange.shade800,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }

        final newUser = UserModel(
          fullName: _fullNameCtrl.text.trim(),
          email: email,
          password: _passwordCtrl.text.trim(),
          role: _selectedRole,
        );

        await DatabaseHelper.instance.registerUser(newUser);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Usuario registrado con éxito. Inicia sesión.'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Oculta el teclado al tocar fuera
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // 1. Imagen de Fondo Representativa de Registro / Bienvenida / Trabajo
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1200&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Overlay para mejorar el contraste del texto sobre el fondo
            Container(
              color: Colors.black.withOpacity(0.50),
            ),

            // 2. Tarjeta Glassmorphism
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(26.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Crear Cuenta',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Completa los datos para dar de alta a un nuevo usuario.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey.shade600,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Campo: Nombre Completo
                              _buildTextField(
                                controller: _fullNameCtrl,
                                label: 'Nombre Completo',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
                              ),
                              const SizedBox(height: 14),

                              // Campo: Correo Electrónico
                              _buildTextField(
                                controller: _emailCtrl,
                                label: 'Correo Electrónico',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Ingresa un correo';
                                  if (!v.contains('@') || !v.contains('.')) return 'Correo no válido';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Campo: Contraseña
                              _buildTextField(
                                controller: _passwordCtrl,
                                label: 'Contraseña',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.blueGrey.shade400,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) => v == null || v.length < 4 ? 'Mínimo 4 caracteres' : null,
                              ),
                              const SizedBox(height: 14),

                              // Campo: Rol en la plataforma
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: _inputDecoration(
                                  label: 'Rol en la plataforma',
                                  icon: Icons.admin_panel_settings_outlined,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                items: ['Administrador', 'Operador de Bodega', 'Supervisor']
                                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedRole = val!),
                              ),
                              const SizedBox(height: 28),

                              // Botón de Acción
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C3E50),
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _register,
                                  child: _isLoading
                                      ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                      : const Text(
                                    'Registrar Cuenta',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: _inputDecoration(label: label, icon: icon, suffixIcon: suffixIcon),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.blueGrey.shade600, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.blueGrey.shade500),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50.withOpacity(0.85),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
    );
  }
}
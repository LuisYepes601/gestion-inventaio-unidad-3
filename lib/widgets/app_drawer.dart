import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/preferences_service.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final UserModel user;

  const AppDrawer({super.key, required this.user});

  void _logout(BuildContext context) async {
    await PreferencesService.clearUserSession();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.fullName.isNotEmpty ? user.fullName : 'Usuario'),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.blueGrey),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Gestión de Inventario'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Rol asignado'),
            subtitle: Text(user.role),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
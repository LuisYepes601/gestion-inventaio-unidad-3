import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// Gestiona la sesión activa con SharedPreferences
class PreferencesService {
  static const String _sessionKey = 'sesion_usuario_activa';

  // Guarda los datos del usuario logueado en la memoria local
  static Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.toJson());
  }

  // Obtiene el usuario logueado
  static Future<UserModel?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_sessionKey);
    if (userJson == null || userJson.isEmpty) return null;
    return UserModel.fromJson(userJson);
  }

  // Cierra la sesión
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
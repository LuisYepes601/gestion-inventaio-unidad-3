import 'dart:convert';

// Modelo de datos para gestionar la entidad de usuario en la base de datos
class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final String role;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });

  // Convierte el objeto a Mapa para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  // Reconstruye el objeto desde una consulta de SQLite
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'Operador',
    );
  }

  // Serialización para guardar en SharedPreferences
  String toJson() => json.encode(toMap());
  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}
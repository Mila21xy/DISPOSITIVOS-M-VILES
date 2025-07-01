import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registro con email y contraseña
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Crear documento de usuario en Firestore
        await _createUserDocument(user, name);

        // Actualizar el nombre del usuario en Firebase Auth
        await user.updateDisplayName(name);
      }

      return result;
    } catch (e) {
      print('Error en registro: $e');
      return null;
    }
  }

  // Inicio de sesión con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Actualizar última conexión
        await _updateLastLogin(user.uid);
      }

      return result;
    } catch (e) {
      print('Error en inicio de sesión: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Crear documento de usuario en Firestore
  Future<void> _createUserDocument(User user, String name) async {
    try {
      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: user.email ?? '',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
    } catch (e) {
      print('Error al crear documento de usuario: $e');
    }
  }

  // Actualizar última conexión
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error al actualizar última conexión: $e');
    }
  }

  // Obtener datos del usuario desde Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  // Actualizar perfil de usuario
  Future<bool> updateUserProfile({
    required String userId,
    required String name,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
      });

      // Actualizar también en Firebase Auth
      await currentUser?.updateDisplayName(name);

      return true;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return false;
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error al restablecer contraseña: $e');
      return false;
    }
  }
}
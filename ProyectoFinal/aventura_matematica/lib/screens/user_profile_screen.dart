import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/game_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  final GameService _gameService = GameService();

  UserModel? _currentUser;
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _authService.currentUser;
      if (user != null) {
        // Cargar datos del usuario
        UserModel? userData = await _authService.getUserData(user.uid);
        if (userData != null) {
          _currentUser = userData;
          _nameController.text = userData.name;
        }

        // Cargar estadísticas del usuario
        Map<String, dynamic> stats = await _gameService.getUserStats(user.uid);
        _userStats = stats;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar datos del usuario: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos del perfil')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      User? user = _authService.currentUser;
      if (user != null) {
        bool success = await _authService.updateUserProfile(
          userId: user.uid,
          name: _nameController.text.trim(),
        );

        if (success) {
          setState(() {
            _currentUser = _currentUser?.copyWith(name: _nameController.text.trim());
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Perfil actualizado correctamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar el perfil')),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al guardar perfil: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los cambios')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade100, Colors.white],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _loadUserData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 30),
                _buildProfileHeader(),
                SizedBox(height: 30),
                _buildUserInfoCard(),
                SizedBox(height: 20),
                _buildStatsCard(),
                SizedBox(height: 20),
                _buildDetailedStatsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.deepPurple,
          child: Text(
            _currentUser?.name.isNotEmpty == true
                ? _currentUser!.name[0].toUpperCase()
                : 'U',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 15),
        Text(
          _currentUser?.name ?? 'Usuario',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          _currentUser?.email ?? '',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Información del Usuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 45),
              ),
              child: _isSaving
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Guardar Cambios',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Estadísticas Principales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 15),
            _buildStatRow('Partidas Jugadas', '${_userStats['totalGamesPlayed'] ?? 0}'),
            _buildStatRow('Mejor Puntaje', '${_userStats['bestScore'] ?? 0}'),
            _buildStatRow('Nivel Favorito', '${_userStats['favoriteLevel'] ?? 'Ninguno'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStatsCard() {
    if (_userStats['totalGamesPlayed'] == 0) {
      return Card(
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.sports_esports,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 10),
              Text(
                '¡Comienza a jugar!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Juega tu primera partida para ver estadísticas detalladas',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Estadísticas Detalladas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 15),
            _buildStatRow(
                'Puntaje Promedio',
                '${_userStats['averageScore'] ?? 0}'
            ),
            _buildStatRow(
                'Respuestas Correctas',
                '${_userStats['totalCorrectAnswers'] ?? 0}'
            ),
            _buildStatRow(
                'Total de Preguntas',
                '${_userStats['totalQuestions'] ?? 0}'
            ),
            _buildStatRow(
                'Precisión Promedio',
                '${_userStats['averageAccuracy'] ?? 0}%'
            ),
            SizedBox(height: 10),
            _buildAccuracyIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              )
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyIndicator() {
    double accuracy = (_userStats['averageAccuracy'] ?? 0.0) / 100;
    Color indicatorColor;

    if (accuracy >= 0.8) {
      indicatorColor = Colors.green;
    } else if (accuracy >= 0.6) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.red;
    }

    return Column(
      children: [
        Text(
          'Nivel de Precisión',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: accuracy,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          minHeight: 8,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
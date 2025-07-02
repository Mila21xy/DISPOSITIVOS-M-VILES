import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/game_service.dart';
import '../models/game_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final GameService _gameService = GameService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<GameModel> _gameHistory = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadGameHistory();
  }

  Future<void> _loadGameHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      User? user = _auth.currentUser;
      if (user != null) {
        if (kDebugMode) {
          print('Usuario autenticado: ${user.uid}');
        }
        List<GameModel> history = await _gameService.getUserGameHistory(user.uid);
        if (kDebugMode) {
          print('Historial obtenido: ${history.length} partidas');
          // Debug: imprimir los datos de cada partida
          for (var game in history) {
            print('Game ID: ${game.id}, Level: ${game.level}, Score: ${game.score}, Date: ${game.playedAt}');
          }
        }

        setState(() {
          _gameHistory = history;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en _loadGameHistory: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      setState(() {
        _errorMessage = 'Error al cargar el historial: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Partidas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadGameHistory,
            tooltip: 'Actualizar historial',
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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando historial...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el historial',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadGameHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_gameHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay partidas registradas aún',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¡Juega tu primera partida para ver tu historial!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGameHistory,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Tus partidas anteriores',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total de partidas: ${_gameHistory.length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ..._gameHistory.map((game) => _buildHistoryCard(game)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(GameModel game) {
    try {
      // game.playedAt ya es un DateTime según el modelo
      String formattedDate = _formatDate(game.playedAt);

      // Obtener color y nombre del nivel usando los métodos del modelo
      Color levelColor = _getLevelColor(game.level);
      String levelName = game.levelDisplayName;

      // Usar las propiedades del modelo directamente
      int correctAnswers = game.correctAnswers;
      int totalQuestions = game.totalQuestions;

      // El modelo ya tiene la propiedad percentage calculada
      double percentage = game.percentage;

      // Formatear el tiempo promedio
      String averageTimeFormatted = game.averageTime.toStringAsFixed(1);

      return Card(
        elevation: 5,
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getLevelIcon(game.level),
                  color: levelColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nivel $levelName',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Preguntas correctas: $correctAnswers/$totalQuestions',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Precisión: ${percentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Tiempo promedio: ${averageTimeFormatted}s',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${game.score}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    'puntos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error al construir tarjeta de historial: $e');
        print('Game data: ${game.toMap()}');
      }
      // Retornar una tarjeta de error en caso de problemas
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.red.shade400,
                size: 30,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Error al mostrar esta partida',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    try {
      List<String> months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];

      String day = date.day.toString().padLeft(2, '0');
      String month = months[date.month - 1];
      String year = date.year.toString();
      String hour = date.hour.toString().padLeft(2, '0');
      String minute = date.minute.toString().padLeft(2, '0');

      return '$day $month $year - $hour:$minute';
    } catch (e) {
      if (kDebugMode) {
        print('Error al formatear fecha: $e');
      }
      return 'Fecha no disponible';
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'freestyle':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_very_dissatisfied;
      case 'freestyle':
        return Icons.all_inclusive;
      default:
        return Icons.games;
    }
  }
}
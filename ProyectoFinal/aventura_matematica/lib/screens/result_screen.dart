import 'package:flutter/material.dart';
import '../models/game_model.dart';
import 'home_screen.dart';
import 'level_selection_screen.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final String level;
  final double averageTime;
  final GameModel gameResult;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.level,
    required this.averageTime,
    required this.gameResult,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
    String performanceLevel = _getPerformanceLevel(percentage);
    IconData performanceIcon = _getPerformanceIcon(percentage);
    Color performanceColor = _getPerformanceColor(percentage);
    bool isFreestyleMode = level == 'freestyle';

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade100, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Medalla/Icono de rendimiento
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  performanceIcon,
                  size: 80,
                  color: performanceColor,
                ),
              ),
              SizedBox(height: 20),

              // Mensaje de felicitación
              Text(
                isFreestyleMode ? '¡Desafío completado!' : performanceLevel,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),

              // Mensaje especial para freestyle
              if (isFreestyleMode) ...[
                SizedBox(height: 10),
                Text(
                  'Respondiste $totalQuestions preguntas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else if (percentage >= 90) ...[
                SizedBox(height: 10),
                Text(
                  '¡Rendimiento excepcional!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              SizedBox(height: 30),

              // Tarjeta de resumen principal
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Text(
                        'Resumen de la partida',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Para freestyle, mostrar estadísticas diferentes
                      if (isFreestyleMode) ...[
                        _buildFreestyleStats(),
                      ] else ...[
                        // Porcentaje circular para modos normales
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: percentage / 100,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    performanceColor,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${percentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: performanceColor,
                                    ),
                                  ),
                                  Text(
                                    'Precisión',
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
                        SizedBox(height: 25),
                        _buildDetailedStats(),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Tarjeta de estadísticas adicionales
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Estadísticas detalladas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Tiempo total',
                              _formatTime(gameResult.totalTime),
                              Icons.timer,
                              Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Tiempo promedio',
                              '${averageTime.toStringAsFixed(1)}s',
                              Icons.speed,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Nivel',
                              gameResult.levelDisplayName,
                              Icons.trending_up,
                              Colors.purple,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Puntaje final',
                              score.toString(),
                              Icons.stars,
                              Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Botones de acción
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LevelSelectionScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.refresh, color: Colors.white),
                          label: Text('Jugar de Nuevo',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                                  (route) => false,
                            );
                          },
                          icon: Icon(Icons.home, color: Colors.white),
                          label: Text('Menú Principal',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 15),

                  // Botón para compartir (ajustado para freestyle)
                  if ((isFreestyleMode && totalQuestions >= 10) || (!isFreestyleMode && percentage >= 80))
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showShareDialog(context, percentage, isFreestyleMode);
                        },
                        icon: Icon(Icons.share, color: Colors.deepPurple),
                        label: Text('Compartir resultado',
                            style: TextStyle(color: Colors.deepPurple)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.deepPurple),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreestyleStats() {
    return Column(
      children: [
        // Estadísticas centrales para freestyle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFreestyleStat('Preguntas', totalQuestions.toString(), Icons.quiz),
            _buildFreestyleStat('Correctas', correctAnswers.toString(), Icons.check_circle),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFreestyleStat('Puntaje', score.toString(), Icons.stars),
            _buildFreestyleStat('Precisión', '${((correctAnswers / totalQuestions) * 100).toStringAsFixed(0)}%', Icons.trending_up),
          ],
        ),
      ],
    );
  }

  Widget _buildFreestyleStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.deepPurple),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStats() {
    return Column(
      children: [
        _buildResultRow('Nivel:', gameResult.levelDisplayName),
        _buildResultRow('Preguntas correctas:', '$correctAnswers/$totalQuestions'),
        _buildResultRow('Preguntas incorrectas:', '${totalQuestions - correctAnswers}/$totalQuestions'),
        _buildResultRow('Porcentaje:', '${gameResult.percentage.toStringAsFixed(1)}%'),
        _buildResultRow('Puntaje total:', score.toString()),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPerformanceLevel(double percentage) {
    if (percentage >= 90) return '¡Excelente!';
    if (percentage >= 80) return '¡Muy bien!';
    if (percentage >= 70) return '¡Bien hecho!';
    if (percentage >= 60) return '¡Buen intento!';
    return '¡Sigue practicando!';
  }

  IconData _getPerformanceIcon(double percentage) {
    if (percentage >= 90) return Icons.emoji_events;
    if (percentage >= 80) return Icons.star;
    if (percentage >= 70) return Icons.thumb_up;
    if (percentage >= 60) return Icons.sentiment_satisfied;
    return Icons.sentiment_neutral;
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 90) return Colors.amber;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 70) return Colors.lightGreen;
    if (percentage >= 60) return Colors.orange;
    return Colors.grey;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  void _showShareDialog(BuildContext context, double percentage, bool isFreestyle) {
    String shareMessage = isFreestyle
        ? '¡Completé el desafío Freestyle con $totalQuestions preguntas respondidas!'
        : '¡Obtuve ${percentage.toStringAsFixed(0)}% de precisión en el nivel ${gameResult.levelDisplayName}!';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Excelente resultado!'),
          content: Text(
            '$shareMessage\n\n'
                'Función de compartir será implementada próximamente.',
          ),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
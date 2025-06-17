import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'level_selection_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String level;

  const ResultScreen({super.key,
    required this.score,
    required this.totalQuestions,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = (score / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados',
            style: TextStyle(
                color: Colors.white
            )
        ),
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
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                percentage >= 70 ? Icons.emoji_events : Icons.sentiment_satisfied,
                size: 80,
                color: percentage >= 70 ? Colors.orangeAccent : Colors.orange,
              ),
              SizedBox(height: 20),
              Text(
                percentage >= 70 ? '¡Excelente!' : '¡Buen intento!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 30),
              Card(
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        'Resumen de la partida',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildResultRow('Nivel:', level.toUpperCase()),
                      _buildResultRow('Preguntas correctas:', '$score/$totalQuestions'),
                      _buildResultRow('Porcentaje:', '${percentage.toStringAsFixed(1)}%'),
                      _buildResultRow('Tiempo promedio:', '15s'),
                      _buildResultRow('Puntaje total:', '${score * 10}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LevelSelectionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text('Jugar de Nuevo',
                          style: TextStyle(
                              color: Colors.white
                          )
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                              (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text('Menú Principal',
                          style: TextStyle(
                              color: Colors.white
                          )
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

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
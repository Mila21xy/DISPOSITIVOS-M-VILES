import 'package:flutter/material.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Nivel',
            style: TextStyle(
                color: Colors.white
            )),
        backgroundColor: Colors.deepPurple,
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
            children: [
              SizedBox(height: 30),
              Text(
                'Elige tu nivel de dificultad',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLevelCard(
                      context,
                      'Fácil',
                      'Suma y resta (1-10)',
                      '30 segundos por pregunta',
                      Colors.green,
                      Icons.sentiment_very_satisfied,
                      'easy',
                    ),
                    _buildLevelCard(
                      context,
                      'Medio',
                      'Suma, resta, multiplicación (1-20)',
                      '20 segundos por pregunta',
                      Colors.orange,
                      Icons.sentiment_satisfied,
                      'medium',
                    ),
                    _buildLevelCard(
                      context,
                      'Difícil',
                      'Todas las operaciones + división',
                      '10 segundos por pregunta',
                      Colors.red,
                      Icons.sentiment_very_dissatisfied,
                      'hard',
                    ),
                    _buildLevelCard(
                      context,
                      'Libre',
                      'Todas las operaciones',
                      '60 segundos por pregunta',
                      Colors.blue,
                      Icons.sentiment_neutral_outlined,
                      'freestyle',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, String title, String description,
      String timeLimit, Color color, IconData icon, String level) {
    return Card(
      elevation: 8,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(level: level),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade100, Colors.white],
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 50,
                color: color,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      timeLimit,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
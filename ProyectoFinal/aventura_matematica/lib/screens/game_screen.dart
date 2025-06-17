import 'package:flutter/material.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final String level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int currentQuestion = 1;
  int totalQuestions = 10;
  int score = 0;
  int timeLeft = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nivel ${widget.level.toUpperCase()}',
            style: TextStyle(
                color: Colors.white
            )
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                '$timeLeft s',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
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
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Progreso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pregunta $currentQuestion/$totalQuestions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Puntaje: $score',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(
                value: currentQuestion / totalQuestions,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
              SizedBox(height: 40),

              // Pregunta
              Card(
                elevation: 8,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        '¿Cuánto es?',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '5 + 3 = ?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Opciones de respuesta
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildAnswerButton('6'),
                    _buildAnswerButton('8'),
                    _buildAnswerButton('7'),
                    _buildAnswerButton('9'),
                  ],
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        score: score,
                        totalQuestions: totalQuestions,
                        level: widget.level,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text('Terminar Juego',
                    style: TextStyle(
                        color: Colors.white
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String answer) {
    return ElevatedButton(
      onPressed: () {
        // Funcionalidad de respuesta será implementada después
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Respuesta seleccionada: $answer')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Text(
        answer,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
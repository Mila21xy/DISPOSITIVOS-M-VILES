import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Partidas',
            style: TextStyle(
                color: Colors.white
            )
        ),
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
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Text(
              'Tus partidas anteriores',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 20),
            _buildHistoryCard(
              date: '15 Jun 2025 - 14:30',
              level: 'FÁCIL',
              score: 80,
              questions: '8/10',
              color: Colors.green,
            ),
            _buildHistoryCard(
              date: '14 Jun 2025 - 16:15',
              level: 'MEDIO',
              score: 60,
              questions: '6/10',
              color: Colors.orange,
            ),
            _buildHistoryCard(
              date: '13 Jun 2025 - 18:45',
              level: 'DIFÍCIL',
              score: 40,
              questions: '4/10',
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Funcionalidad completa será implementada\ncon base de datos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String level,
    required int score,
    required String questions,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.20),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.games,
                color: color,
                size: 30,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Nivel $level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'Preguntas correctas: $questions',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '$score',
                  style: TextStyle(
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
  }
}
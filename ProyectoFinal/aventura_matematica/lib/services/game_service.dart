import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/game_model.dart';
import '../models/user_model.dart';
import 'dart:math';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generar preguntas según el nivel
  List<Question> generateQuestions(String level, int count) {
    List<Question> questions = [];
    Random random = Random();

    for (int i = 0; i < count; i++) {
      Question question = _generateQuestion(level, random);
      questions.add(question);
    }

    return questions;
  }

  Question _generateQuestion(String level, Random random) {
    List<String> operations = [];
    int maxNumber = 0;

    switch (level) {
      case 'easy':
        operations = ['+', '-'];
        maxNumber = 10;
        break;
      case 'medium':
        operations = ['+', '-', '*'];
        maxNumber = 20;
        break;
      case 'hard':
        operations = ['+', '-', '*', '/'];
        maxNumber = 30;
        break;
      case 'freestyle':
        operations = ['+', '-', '*', '/'];
        maxNumber = 50;
        break;
    }

    String operation = operations[random.nextInt(operations.length)];
    int num1, num2, correctAnswer;
    String questionText;

    switch (operation) {
      case '+':
        num1 = random.nextInt(maxNumber) + 1;
        num2 = random.nextInt(maxNumber) + 1;
        correctAnswer = num1 + num2;
        questionText = '$num1 + $num2 = ?';
        break;
      case '-':
        num1 = random.nextInt(maxNumber) + 1;
        num2 = random.nextInt(num1) + 1;
        correctAnswer = num1 - num2;
        questionText = '$num1 - $num2 = ?';
        break;
      case '*':
        num1 = random.nextInt(min(maxNumber ~/ 2, 12)) + 1;
        num2 = random.nextInt(min(maxNumber ~/ 2, 12)) + 1;
        correctAnswer = num1 * num2;
        questionText = '$num1 × $num2 = ?';
        break;
      case '/':
      // Generar división exacta
        num2 = random.nextInt(min(maxNumber ~/ 3, 10)) + 2;
        correctAnswer = random.nextInt(min(maxNumber ~/ num2, 15)) + 1;
        num1 = num2 * correctAnswer;
        questionText = '$num1 ÷ $num2 = ?';
        break;
      default:
        num1 = 1;
        num2 = 1;
        correctAnswer = 2;
        questionText = '1 + 1 = ?';
    }

    // Generar opciones incorrectas
    List<int> options = [correctAnswer];
    while (options.length < 4) {
      int wrongAnswer;
      if (correctAnswer <= 5) {
        wrongAnswer = random.nextInt(10) + 1;
      } else {
        int variation = max(correctAnswer ~/ 3, 1);
        wrongAnswer = correctAnswer + (random.nextInt(variation * 2) - variation);
        if (wrongAnswer <= 0) wrongAnswer = 1;
      }

      if (!options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }

    options.shuffle();

    return Question(
      operation: questionText,
      correctAnswer: correctAnswer,
      options: options,
      operationType: operation,
    );
  }

  // Guardar resultado del juego
  Future<bool> saveGameResult(GameModel game) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Guardar el juego
      await _firestore.collection('games').add(game.toMap());

      // Actualizar estadísticas del usuario
      await _updateUserStats(user.uid, game);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al guardar resultado del juego: $e');
      }
      return false;
    }
  }

  // Actualizar estadísticas del usuario
  Future<void> _updateUserStats(String userId, GameModel game) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        int currentGamesPlayed = userData['totalGamesPlayed'] ?? 0;
        int currentBestScore = userData['bestScore'] ?? 0;

        // Actualizar estadísticas
        await userRef.update({
          'totalGamesPlayed': currentGamesPlayed + 1,
          'bestScore': max(currentBestScore, game.score),
          'favoriteLevel': game.level,
          'lastLogin': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar estadísticas: $e');
      }
    }
  }

  // Obtener historial de juegos del usuario
  Future<List<GameModel>> getUserGameHistory(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('games')
          .where('userId', isEqualTo: userId)
          .orderBy('playedAt', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return GameModel.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener historial: $e');
      }
      return [];
    }
  }

  // Obtener estadísticas del usuario
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Obtener datos del usuario
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return {
          'totalGamesPlayed': 0,
          'bestScore': 0,
          'favoriteLevel': 'Ninguno',
          'averageScore': 0.0,
          'averageAccuracy': 0.0,
        };
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Obtener estadísticas de los juegos
      QuerySnapshot gamesSnapshot = await _firestore
          .collection('games')
          .where('userId', isEqualTo: userId)
          .get();

      List<GameModel> games = gamesSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return GameModel.fromMap(data);
      }).toList();

      double averageScore = 0.0;
      double averageAccuracy = 0.0;

      if (games.isNotEmpty) {
        averageScore = games.map((g) => g.score).reduce((a, b) => a + b) / games.length;
        averageAccuracy = games.map((g) => g.percentage).reduce((a, b) => a + b) / games.length;
      }

      String favoriteLevel = userData['favoriteLevel'] ?? 'Ninguno';
      if (favoriteLevel != 'Ninguno') {
        switch (favoriteLevel) {
          case 'easy':
            favoriteLevel = 'Fácil';
            break;
          case 'medium':
            favoriteLevel = 'Medio';
            break;
          case 'hard':
            favoriteLevel = 'Difícil';
            break;
          case 'freestyle':
            favoriteLevel = 'Libre';
            break;
        }
      }

      return {
        'totalGamesPlayed': userData['totalGamesPlayed'] ?? 0,
        'bestScore': userData['bestScore'] ?? 0,
        'favoriteLevel': favoriteLevel,
        'averageScore': averageScore.round(),
        'averageAccuracy': averageAccuracy.round(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener estadísticas: $e');
      }
      return {
        'totalGamesPlayed': 0,
        'bestScore': 0,
        'favoriteLevel': 'Ninguno',
        'averageScore': 0,
        'averageAccuracy': 0,
      };
    }
  }

  // Obtener tiempo límite según el nivel
  int getTimeLimitForLevel(String level) {
    switch (level) {
      case 'easy':
        return 30;
      case 'medium':
        return 20;
      case 'hard':
        return 10;
      case 'freestyle':
        return 60;
      default:
        return 30;
    }
  }
}
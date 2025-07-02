import 'package:flutter/material.dart';
import 'dart:async';
import '../models/game_model.dart';
import '../services/game_service.dart';
import '../services/auth_service.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final String level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GameService();
  final AuthService _authService = AuthService();

  int currentQuestionIndex = 0;
  int totalQuestions = 10;
  int score = 0;
  int correctAnswers = 0;
  int timeLeft = 30;
  Timer? _timer;

  List<Question> questions = [];
  bool isLoading = true;
  bool hasAnswered = false;
  int? selectedAnswer;
  DateTime questionStartTime = DateTime.now();
  List<int> answerTimes = [];

  // Variables específicas para freestyle ilimitado
  bool isFreestyleMode = false;
  int questionsAnswered = 0;

  @override
  void initState() {
    super.initState();
    isFreestyleMode = widget.level == 'freestyle';
    _initializeGame();
  }

  void _initializeGame() {
    // Para freestyle, generar preguntas iniciales y marcar como ilimitado
    if (isFreestyleMode) {
      totalQuestions = -1; // -1 indica ilimitado
      questions = _gameService.generateQuestions(widget.level, 5); // Generar 5 iniciales
    } else {
      questions = _gameService.generateQuestions(widget.level, totalQuestions);
    }

    timeLeft = _gameService.getTimeLimitForLevel(widget.level);

    setState(() {
      isLoading = false;
    });

    _startTimer();
    questionStartTime = DateTime.now();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        _timeUp();
      }
    });
  }

  void _timeUp() {
    if (!hasAnswered) {
      _answerQuestion(-1); // -1 indica tiempo agotado
    }
  }

  void _answerQuestion(int selectedOption) {
    if (hasAnswered) return;

    _timer?.cancel();

    // Calcular tiempo de respuesta
    int responseTime = DateTime.now().difference(questionStartTime).inSeconds;
    answerTimes.add(responseTime);

    setState(() {
      hasAnswered = true;
      selectedAnswer = selectedOption;
    });

    // Verificar si la respuesta es correcta
    bool isCorrect = selectedOption == questions[currentQuestionIndex].correctAnswer;

    if (isCorrect) {
      correctAnswers++;
      // Calcular puntos basado en tiempo restante y dificultad
      int points = _calculatePoints();
      score += points;
    }

    questionsAnswered++;

    // Mostrar feedback visual
    Future.delayed(Duration(milliseconds: 1500), () {
      _nextQuestion();
    });
  }

  int _calculatePoints() {
    int basePoints = 10;
    int timeBonus = timeLeft;

    switch (widget.level) {
      case 'easy':
        return basePoints + timeBonus;
      case 'medium':
        return (basePoints + timeBonus) * 2;
      case 'hard':
        return (basePoints + timeBonus) * 3;
      case 'freestyle':
        return (basePoints + timeBonus) * 2;
      default:
        return basePoints;
    }
  }

  void _nextQuestion() {
    if (isFreestyleMode) {
      // En modo freestyle, generar nueva pregunta si es necesario
      if (currentQuestionIndex >= questions.length - 1) {
        // Generar más preguntas
        List<Question> newQuestions = _gameService.generateQuestions(widget.level, 5);
        questions.addAll(newQuestions);
      }

      setState(() {
        currentQuestionIndex++;
        hasAnswered = false;
        selectedAnswer = null;
        timeLeft = _gameService.getTimeLimitForLevel(widget.level);
      });
      questionStartTime = DateTime.now();
      _startTimer();
    } else {
      // Modo normal con límite de preguntas
      if (currentQuestionIndex < totalQuestions - 1) {
        setState(() {
          currentQuestionIndex++;
          hasAnswered = false;
          selectedAnswer = null;
          timeLeft = _gameService.getTimeLimitForLevel(widget.level);
        });
        questionStartTime = DateTime.now();
        _startTimer();
      } else {
        _endGame();
      }
    }
  }

  void _endGame() async {
    _timer?.cancel();

    // Calcular estadísticas
    double averageTime = answerTimes.isEmpty ? 0 :
    answerTimes.reduce((a, b) => a + b) / answerTimes.length;

    // Para freestyle, usar questionsAnswered como totalQuestions
    int finalTotalQuestions = isFreestyleMode ? questionsAnswered : totalQuestions;

    // Crear modelo de juego
    GameModel gameResult = GameModel(
      id: '',
      userId: _authService.currentUser?.uid ?? '',
      level: widget.level,
      score: score,
      correctAnswers: correctAnswers,
      totalQuestions: finalTotalQuestions,
      totalTime: answerTimes.reduce((a, b) => a + b),
      playedAt: DateTime.now(),
      averageTime: averageTime,
    );

    // Guardar resultado
    if (_authService.currentUser != null) {
      await _gameService.saveGameResult(gameResult);
    }

    // Navegar a pantalla de resultados
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: score,
          totalQuestions: finalTotalQuestions,
          correctAnswers: correctAnswers,
          level: widget.level,
          averageTime: averageTime,
          gameResult: gameResult,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        ),
      );
    }

    Question currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Nivel ${widget.level.toUpperCase()}',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: timeLeft <= 5 ? Colors.red : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${timeLeft}s',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                    isFreestyleMode
                        ? 'Pregunta ${questionsAnswered + 1}'
                        : 'Pregunta ${currentQuestionIndex + 1}/$totalQuestions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Puntaje: $score',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Barra de progreso (solo para modos con límite)
              if (!isFreestyleMode) ...[
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / totalQuestions,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ] else ...[
                // Para freestyle, mostrar una barra de "actividad"
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: List.generate(10, (index) =>
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: (index % 3 == (questionsAnswered % 3))
                                  ? Colors.white
                                  : Colors.deepPurple.shade300,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                    ),
                  ),
                ),
              ],

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
                        currentQuestion.operation,
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
                  children: currentQuestion.options.map((option) {
                    return _buildAnswerButton(option);
                  }).toList(),
                ),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showEndGameDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text('Terminar Juego',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(int answer) {
    Color backgroundColor = Colors.white;
    Color textColor = Colors.deepPurple;

    if (hasAnswered && selectedAnswer == answer) {
      backgroundColor = answer == questions[currentQuestionIndex].correctAnswer
          ? Colors.green
          : Colors.red;
      textColor = Colors.white;
    } else if (hasAnswered && answer == questions[currentQuestionIndex].correctAnswer) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
    }

    return ElevatedButton(
      onPressed: hasAnswered ? null : () => _answerQuestion(answer),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Text(
        answer.toString(),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showEndGameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Terminar juego?'),
          content: Text(
              isFreestyleMode
                  ? '¿Estás seguro de que quieres terminar el juego? Has respondido $questionsAnswered preguntas.'
                  : '¿Estás seguro de que quieres terminar el juego actual?'
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Terminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _endGame();
              },
            ),
          ],
        );
      },
    );
  }
}
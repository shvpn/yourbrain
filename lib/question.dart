import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FlagImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  FlagImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 200,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,

      // Placeholder while loading
      placeholder:
          (context, url) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            ),
          ),

      // Error widget if image fails to load
      errorWidget:
          (context, url, error) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.error_outline, color: Colors.red, size: 48),
            ),
          ),

      // Optional: Cache management
      //memCacheWidth: 400,
      //memCacheHeight: 240,

      // Optional: Customizing cache behavior
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String type; // Added type field for question types
  final String? imageUrl;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.type = 'multiple_choice', // Default type
    this.imageUrl,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      type: json['type'] ?? 'multiple_choice',
      imageUrl: json['imageUrl'],
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String category;
  final String apiUrl;

  const QuizScreen({super.key, required this.category, required this.apiUrl});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  int? selectedAnswerIndex;
  int timeLeft = 15; // 15 seconds per question
  Timer? _timer;
  bool isLoading = true;
  String? errorMessage;
  List<QuizQuestion> questions = [];

  // Animation controllers
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for smooth progress bar
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_progressAnimationController);

    _progressAnimationController.addListener(() {
      setState(() {
        // This empty setState forces a rebuild when animation updates
      });
    });

    fetchQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressAnimationController.dispose();
    super.dispose();
  }

  Future<void> fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse(widget.apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Convert all fetched questions to QuizQuestion objects
        List<QuizQuestion> allQuestions =
            data.map((item) => QuizQuestion.fromJson(item)).toList();

        // Shuffle the questions to randomize selection
        allQuestions.shuffle();

        // Take only the first 10 questions (or less if fewer are available)
        const int questionLimit = 10;
        final List<QuizQuestion> selectedQuestions =
            allQuestions.length > questionLimit
                ? allQuestions.sublist(0, questionLimit)
                : allQuestions;

        setState(() {
          questions = selectedQuestions;
          isLoading = false;
        });
        startTimer();
      } else {
        setState(() {
          errorMessage =
              'Failed to load questions. Server returned ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching questions: $e';
        isLoading = false;
      });

      // Load fallback questions if network fetch fails
      loadFallbackQuestions();
    }
  }

  // Also update the fallback questions method to respect the 10 question limit
  void loadFallbackQuestions() {
    final fallbackQuestions = [
      QuizQuestion(
        question: "What is the capital of France?",
        options: ["London", "Berlin", "Paris", "Madrid"],
        correctAnswerIndex: 2,
        type: 'multiple_choice',
      ),
      QuizQuestion(
        question: "Which planet is known as the Red Planet?",
        options: ["Venus", "Mars", "Jupiter", "Saturn"],
        correctAnswerIndex: 1,
        type: 'multiple_choice',
      ),
      // Add more fallback questions as needed
    ];

    // Take at most 10 fallback questions
    const int questionLimit = 10;
    final List<QuizQuestion> selectedQuestions =
        fallbackQuestions.length > questionLimit
            ? fallbackQuestions.sublist(0, questionLimit)
            : fallbackQuestions;

    setState(() {
      questions = selectedQuestions;
      isLoading = false;
    });
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    setState(() {
      timeLeft = 15;
    });

    // Reset and start the animation controller for smooth progress
    _progressAnimationController.reset();
    _progressAnimationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            timer.cancel();
            if (!isAnswered) {
              // Time's up without answering
              checkAnswer(-1); // -1 means no answer
            }
          }
        });
      }
    });
  }

  void checkAnswer(int selectedIndex) {
    // Stop the timer and animation
    _timer?.cancel();
    _progressAnimationController.stop();

    setState(() {
      isAnswered = true;
      selectedAnswerIndex = selectedIndex;

      // Check answer based on question type
      if (currentQuestionIndex < questions.length) {
        QuizQuestion currentQuestion = questions[currentQuestionIndex];

        if (currentQuestion.type == 'true_false') {
          // For true/false questions
          if (selectedIndex == currentQuestion.correctAnswerIndex) {
            score++;
          }
        } else if (currentQuestion.type == 'other') {
          // For other question types that might need special handling
          if (selectedIndex == currentQuestion.correctAnswerIndex) {
            score++;
          }
        } else {
          // Default multiple choice
          if (selectedIndex == currentQuestion.correctAnswerIndex) {
            score++;
          }
        }
      }
    });

    // Pause for 1 second to show correct/incorrect, then move to next question
    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          isAnswered = false;
          selectedAnswerIndex = null;
        });
        startTimer();
      } else {
        // Quiz completed
        _timer?.cancel();
        saveScore();
        showResultDialog();
      }
    });
  }

  Future<void> saveScore() async {
    final prefs = await SharedPreferences.getInstance();

    // Get current high score for this category
    final highScore = prefs.getInt('quizHighScore_${widget.category}') ?? 0;

    // Save new high score if current score is higher
    if (score > highScore) {
      await prefs.setInt('quizHighScore_${widget.category}', score);
    }

    // Save history of attempts
    List<String> history =
        prefs.getStringList('quizHistory_${widget.category}') ?? [];
    final timestamp = DateTime.now().toString();
    history.add('$timestamp|$score|${questions.length}');

    // Keep only the last 10 attempts
    if (history.length > 10) {
      history = history.sublist(history.length - 10);
    }

    await prefs.setStringList('quizHistory_${widget.category}', history);
  }

  void showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade200, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Quiz Completed!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Animated score container
                TweenAnimationBuilder(
                  duration: const Duration(seconds: 1),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.deepOrange.shade300,
                          width: 4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${(score * value).toInt()}",
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const Text(
                              "points",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  "You answered $score out of ${questions.length} questions correctly!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  getScoreMessage(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to category screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Home",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        // Reset and start new quiz
                        setState(() {
                          currentQuestionIndex = 0;
                          score = 0;
                          isAnswered = false;
                          selectedAnswerIndex = null;
                        });
                        startTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Try Again",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getScoreMessage() {
    final percentage = (score / questions.length) * 100;
    if (percentage >= 90) return "Wow! Your brain is master!";
    if (percentage >= 75) return "Great job! Your brain is good !";
    if (percentage >= 50) return "Good effort! Your brain need me!";
    return "Your Brain is SHIT!";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.orange.shade300,
          title: Text(
            widget.category,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
              SizedBox(height: 20),
              Text(
                "Loading quiz questions...",
                style: TextStyle(fontSize: 16, color: Colors.deepOrange),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null && questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.orange.shade300,
          title: Text(
            widget.category,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  "Error Loading Questions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    fetchQuestions();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Try Again"),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Go Back"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade300,
        title: Row(
          children: [
            Text(
              widget.category,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Show confirmation dialog before exiting quiz
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Exit Quiz?"),
                  content: const Text(
                    "Are you sure you want to exit? Your progress will be lost.",
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit quiz
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Exit"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Timer indicator with smooth animation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.orange.shade100),
            child: Column(
              children: [
                const Text(
                  "Time Remaining",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timer,
                      color: timeLeft < 5 ? Colors.red : Colors.deepOrange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$timeLeft seconds",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: timeLeft < 5 ? Colors.red : Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Animated smooth progress bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  height: 8,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _progressAnimation.value < 0.3
                                ? Colors.red
                                : Colors.deepOrange,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Question ${currentQuestionIndex + 1}/${questions.length}",
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Question and options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Question with fun animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Display question type badge if not default
                                  // Inside the build method, modify the question display section:
                                  if (questions[currentQuestionIndex]
                                          .imageUrl !=
                                      null)
                                    FlagImageWidget(
                                      imageUrl:
                                          questions[currentQuestionIndex]
                                              .imageUrl!,
                                    ),
                                  if (questions[currentQuestionIndex].type !=
                                      'multiple_choice')
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getQuestionTypeColor(
                                          questions[currentQuestionIndex].type,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        getQuestionTypeLabel(
                                          questions[currentQuestionIndex].type,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    questions[currentQuestionIndex].question,
                                    style: AdaptiveFontStyle.getTextStyle(
                                      context: context,
                                      text:
                                          questions[currentQuestionIndex]
                                              .question,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Options with staggered animation
                  ...List.generate(
                    questions[currentQuestionIndex].options.length,
                    (index) => TweenAnimationBuilder(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(30 * (1 - value), 0),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap:
                                    isAnswered
                                        ? null
                                        : () => checkAnswer(index),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: getOptionColor(index),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: getOptionBorderColor(index),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        offset: const Offset(0, 2),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: getOptionCircleColor(index),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: getOptionBorderColor(index),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            getOptionLabel(
                                              index,
                                              questions[currentQuestionIndex]
                                                  .type,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          questions[currentQuestionIndex]
                                              .options[index],
                                          style: AdaptiveFontStyle.getTextStyle(
                                            context: context,
                                            text:
                                                questions[currentQuestionIndex]
                                                    .options[index],
                                          ),
                                        ),
                                      ),
                                      if (isAnswered &&
                                          index ==
                                              questions[currentQuestionIndex]
                                                  .correctAnswerIndex)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 24,
                                        ),
                                      if (isAnswered &&
                                          index == selectedAnswerIndex &&
                                          index !=
                                              questions[currentQuestionIndex]
                                                  .correctAnswerIndex)
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom score indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      "Score: $score",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
                if (!isAnswered)
                  TextButton(
                    onPressed: () {
                      // Skip question
                      checkAnswer(-1);
                    },
                    child: const Row(
                      children: [
                        Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.skip_next, color: Colors.grey),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for option styling
  Color getOptionColor(int index) {
    if (!isAnswered) {
      return Colors.white;
    } else if (index == questions[currentQuestionIndex].correctAnswerIndex) {
      return Colors.green.shade50;
    } else if (index == selectedAnswerIndex) {
      return Colors.red.shade50;
    } else {
      return Colors.white;
    }
  }

  Color getOptionBorderColor(int index) {
    if (!isAnswered) {
      return Colors.orange.shade300;
    } else if (index == questions[currentQuestionIndex].correctAnswerIndex) {
      return Colors.green;
    } else if (index == selectedAnswerIndex) {
      return Colors.red;
    } else {
      return Colors.grey.shade300;
    }
  }

  Color getOptionCircleColor(int index) {
    if (!isAnswered) {
      return Colors.orange.shade300;
    } else if (index == questions[currentQuestionIndex].correctAnswerIndex) {
      return Colors.green;
    } else if (index == selectedAnswerIndex) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  String getOptionLabel(int index, String questionType) {
    if (questionType == 'true_false') {
      return index == 0 ? 'T' : 'F';
    } else if (questionType == 'other') {
      // Custom labeling for other question types
      return '${index + 1}';
    } else {
      // Default A, B, C, D
      return String.fromCharCode(65 + index);
    }
  }

  // Question type helper methods
  Color getQuestionTypeColor(String type) {
    switch (type) {
      case 'true_false':
        return Colors.purple;
      case 'other':
        return Colors.teal;
      default:
        return Colors.deepOrange;
    }
  }

  String getQuestionTypeLabel(String type) {
    switch (type) {
      case 'true_false':
        return 'TRUE/FALSE';
      case 'other':
        return 'CUSTOM';
      default:
        return 'MULTIPLE CHOICE';
    }
  }
}

// Helper widget to fetch questions from a raw GitHub URL
class QuizApiService {
  static Future<String> getApiUrlForCategory(String category) async {
    // Map categories to their respective GitHub raw URLs
    // You would replace these with your actual GitHub raw URLs
    final Map<String, String> categoryUrls = {
      'General Knowledge':
          'https://raw.githubusercontent.com/shvpn/idmcrack/refs/heads/main/All.txt',
      'Science':
          'https://raw.githubusercontent.com/shvpn/idmcrack/refs/heads/main/sci.txt',
      'Sport':
          'https://raw.githubusercontent.com/shvpn/idmcrack/refs/heads/main/sport.txt',
      'Music':
          'https://raw.githubusercontent.com/shvpn/idmcrack/refs/heads/main/mu.txt',
      'Anime':
          'https://raw.githubusercontent.com/shvpn/idmcrack/refs/heads/main/anime.txt',
      'Movie':
          'https://raw.githubusercontent.com/shvpn/idmcrack/refs/heads/main/movie.txt',
      'Flag':
          'https://raw.githubusercontent.com/shvpn/idmcrack/refs/heads/main/fl.txt',
      // Add more categories as needed
    };

    return categoryUrls[category] ??
        'https://raw.githubusercontent.com/shvpn/idmcrack/refs/heads/main/All.txt'; // Default fallback
  }
}

class AdaptiveFontStyle {
  static TextStyle getTextStyle({
    required BuildContext context,
    required String text,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.black87,
  }) {
    // Check if the text contains Khmer characters
    bool isKhmerText = _containsKhmerCharacters(text);

    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: isKhmerText ? 'Lato' : 'Lato',
    );
  }

  // Helper method to detect Khmer characters
  static bool _containsKhmerCharacters(String text) {
    // Unicode range for Khmer characters
    final khmerRegex = RegExp(r'[\u1780-\u17FF]');
    return khmerRegex.hasMatch(text);
  }
}

// Example JSON format for quiz data on GitHub:
/*

*/

// Example usage in your app:
// /*
// // In your category selection screen
// onPressed: () async {
//   final apiUrl = await QuizApiService.getApiUrlForCategory(categoryName);
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder

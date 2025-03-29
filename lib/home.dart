import 'package:flutter/material.dart';
import 'login.dart';
import 'question.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizHomeScreen extends StatelessWidget {
  const QuizHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Top navigation row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.orange),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.language, color: Colors.orange),
                    onPressed: () {
                      _showDialog(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // App logo and title
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange,
                child: Image.asset("assets/images/logo.png"),
              ),

              const SizedBox(height: 15),

              const Text(
                "Your Brain",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 20),

              // User stats and info buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton("Achievement", Icons.emoji_events),
                    _buildIconButton("Statistics", Icons.bar_chart),
                    _buildIconButton("About", Icons.help_outline),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Category heading
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Category grid
              Expanded(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    return GridView.count(
                      crossAxisCount:
                          orientation == Orientation.portrait ? 2 : 4,
                      padding: const EdgeInsets.all(15.0),
                      crossAxisSpacing:
                          MediaQuery.of(context).size.width * 0.05,
                      mainAxisSpacing: MediaQuery.of(context).size.width * 0.05,
                      children: [
                        _buildCategoryButton(
                          "All",
                          "assets/images/all.png",
                          () async {
                            final apiUrl =
                                await QuizApiService.getApiUrlForCategory(
                                  'General Knowledge',
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizScreen(
                                      category: 'General Knowledge',
                                      apiUrl: apiUrl,
                                    ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryButton(
                          "General Knowledge",
                          "assets/images/gen.png",
                          () async {
                            final apiUrl =
                                await QuizApiService.getApiUrlForCategory(
                                  'General Knowledge',
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizScreen(
                                      category: 'General Knowledge',
                                      apiUrl: apiUrl,
                                    ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryButton(
                          "Sport",
                          "assets/images/sp.png",
                          () async {
                            final apiUrl =
                                await QuizApiService.getApiUrlForCategory(
                                  'Sport',
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizScreen(
                                      category: 'Sport',
                                      apiUrl: apiUrl,
                                    ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryButton(
                          "Science",
                          "assets/images/sc.png",
                          () async {
                            final apiUrl =
                                await QuizApiService.getApiUrlForCategory(
                                  'Science',
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizScreen(
                                      category: 'Secience',
                                      apiUrl: apiUrl,
                                    ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryButton(
                          "Music",
                          "assets/images/mu.png",
                          () async {
                            final apiUrl =
                                await QuizApiService.getApiUrlForCategory(
                                  'Music',
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizScreen(
                                      category: 'Music',
                                      apiUrl: apiUrl,
                                    ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryButton(
                          "Flag",
                          "assets/images/fl.png",
                          () async {
                            final apiUrl =
                                await QuizApiService.getApiUrlForCategory(
                                  'Flag',
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizScreen(
                                      category: 'Flag',
                                      apiUrl: apiUrl,
                                    ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryButton(
                          "Anime",
                          "assets/images/an.png",
                          () async {
                            final apiUrl =
                                await QuizApiService.getApiUrlForCategory(
                                  'Anime',
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizScreen(
                                      category: 'Anime',
                                      apiUrl: apiUrl,
                                    ),
                              ),
                            );
                          },
                        ),
                        _buildCategoryButton(
                          "Movie",
                          "assets/images/mo.png",
                          () async {
                            final apiUrl =
                                await QuizApiService.getApiUrlForCategory(
                                  'Movie',
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => QuizScreen(
                                      category: 'Movie',
                                      apiUrl: apiUrl,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(String label, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.orange.shade100,
          child: Icon(icon, size: 28, color: Colors.orange),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCategoryButton(
    String label,
    String path,
    VoidCallback onPressed,
  ) {
    return Center(
      child: Column(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Image.asset(path, width: 100, height: 100),
            iconSize: 80,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

void _showDialog(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;
  String currentUser = "";

  if (currentUser == "") {
    SharedPreferences.getInstance().then((prefs) {
      currentUser = prefs.getString('username') ?? "";
    });
  }
  print(currentUser);

  // Get the current user

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetAnimationDuration: const Duration(milliseconds: 200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: isSmallScreen ? size.width * 0.85 : 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade300, Colors.deepOrange.shade500],
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
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Profile section
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.person, size: 45, color: Colors.white),
                ],
              ),
              const SizedBox(height: 16),

              // Name container
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  currentUser,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Score section
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Highest Scores",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "89pts",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              _buildButton(context, "Change Name", Icons.edit, () {}),
              _buildButton(context, "Change Password", Icons.lock, () {}),
              _buildButton(context, "Logout", Icons.logout, () {
                logout(context);
              }),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildButton(
  BuildContext context,
  String text,
  IconData icon,
  VoidCallback onPressed,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

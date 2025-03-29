import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'home.dart';
import 'register.dart';
import 'getuser_pass.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

Future<bool> validateUserCredentials(String username, String password) async {
  try {
    // Fetch the users data (assuming this method exists)
    var users = await UsersService.instance.getUsers();

    // Check if the username and password match any user in the API data
    return users
        .any((user) => user['name'] == username && user['pass'] == password);
  } catch (e) {
    // Handle any errors (network, parsing, etc.)

    return false;
  }
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();
  bool isChecked = true;
  String islogin = "";
  String iislogin = "";
  // get user and password in the database

  // Controllers to manage text field values
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check for saved credentials when the app starts
    _loadSavedCredentials();
  }

  // Load saved credentials from SharedPreferences
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      final username = prefs.getString('username') ?? '';
      final password = prefs.getString('password') ?? '';

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        },
      );

      try {
        // Validate saved credentials using the new API-based method
        bool isValidUser = await validateUserCredentials(username, password);

        // Close the loading dialog
        Navigator.of(context).pop();

        if (isValidUser) {
          // Credentials are valid, navigate to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const QuizHomeScreen(),
            ),
          );
        } else {
          // Invalid saved credentials, clear them
          await prefs.remove('username');
          await prefs.remove('password');
          await prefs.setBool('rememberMe', false);

          // Optionally, show a snackbar about invalid saved credentials
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved credentials are no longer valid'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Close the loading dialog
        Navigator.of(context).pop();

        // Handle any errors during validation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating credentials: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Save credentials if "Remember me" is checked
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    if (isChecked) {
      // Save credentials
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      // Clear saved credentials
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Welcome to Your Brain",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Sign into your account",
                      style: TextStyle(color: Colors.grey[800], fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              filled: true,
                              fillColor: Colors.orange.shade50,
                              floatingLabelStyle:
                                  TextStyle(color: Colors.deepOrange.shade300),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.shade300,
                                  width: 2.0,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please input username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true, // Hide password
                            decoration: InputDecoration(
                              labelText: 'Password',
                              filled: true,
                              fillColor: Colors.orange.shade50,
                              floatingLabelStyle:
                                  TextStyle(color: Colors.deepOrange.shade300),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.shade300,
                                  width: 2.0,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please input password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    checkColor: Colors.orange.shade100,
                                    activeColor: Colors.deepOrange.shade300,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked = value ?? true;
                                      });
                                    },
                                  ),
                                  const Text("Remember me")
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Forget password?",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade300,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              // First, validate the form
                              if (_formKey.currentState!.validate()) {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.orange),
                                      ),
                                    );
                                  },
                                );

                                try {
                                  // Validate user credentials
                                  bool isValidUser =
                                      await validateUserCredentials(
                                          _usernameController.text,
                                          _passwordController.text);

                                  // Close the loading dialog
                                  Navigator.of(context).pop();

                                  if (isValidUser) {
                                    // Save credentials if "Remember me" is checked
                                    await _saveCredentials();

                                    // Navigate to home screen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const QuizHomeScreen(),
                                      ),
                                    );
                                  } else {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Invalid username or password'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Close the loading dialog in case of an error
                                  Navigator.of(context).pop();

                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Login failed: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade300,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Register(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade300,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "OR",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Image.asset(
                                  'assets/images/gg.png',
                                  height: 50,
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'assets/images/fb.png',
                                  height: 50,
                                ),
                                iconSize: 50,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

Future<void> logout(BuildContext context) async {
  // Clear all saved credentials from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('username');
  await prefs.remove('password');
  await prefs.setBool('rememberMe', false);

  // Reset any login state variables if needed
  // If these variables are in your state class, you would use setState
  // setState(() {
  //   islogin = "";
  //   iislogin = "";
  // });

  // Navigate back to login screen and clear navigation history
  // so the user can't go back using the back button
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const MyApp(),
    ),
  );
}

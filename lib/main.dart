import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
        primaryColor: Colors.orange.shade200,
      ),
      home: const MyApp(),
    ),
  );
}

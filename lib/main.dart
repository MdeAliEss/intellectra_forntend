import 'package:flutter/material.dart';
import 'package:intellectra/views/course/screens/courses_detail_paeg.dart';
import 'package:intellectra/views/course/screens/add_course_screen.dart';
import 'package:intellectra/views/course/screens/professor_courses_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intellectra',
      home: ProfessorCoursesScreen(professorId: 2),
      debugShowCheckedModeBanner: false,
    );
  }
}

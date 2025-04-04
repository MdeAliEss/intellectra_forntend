import 'package:flutter/material.dart';
import 'package:intellectra/views/course/screens/courses_detail_paeg2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intellectra',
      home: CourseDetailPage2(courseId: 48),
      debugShowCheckedModeBanner: false,
    );
  }
}

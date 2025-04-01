import 'package:flutter/material.dart';
import 'package:intellectra/views/course/courses_detail_paeg.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intellectra',
      home: CourseDetailPage(courseId: 7,),
    );
  }
} 
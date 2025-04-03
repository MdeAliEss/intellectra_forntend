import 'package:flutter/material.dart';
import 'package:intellectra/views/course/models/course_models.dart';
import 'package:intellectra/views/course/services/api_service.dart';

class CoursesDetailPage extends StatefulWidget {
  /// The ID of the course to be displayed.
  final int courseId;
  /// Constructor for the CoursesDetailPage.
  /// Takes a [courseId] as a required parameter.
  const CoursesDetailPage({required this.courseId,super.key});

  @override
  State<CoursesDetailPage> createState() => _CoursesDetailPageState();
}

class _CoursesDetailPageState extends State<CoursesDetailPage> {
  /// Future object to hold the course details.
  late Future<Course> _courseFuture;
  final ApiService _apiService = ApiService();
  /// Current index of the section being viewed.
  int _currentSectionIndex = 0;
  /// PageController to control the page view of the sections.
  final PageController _pageController = PageController();

  
  @override
  void initState(){
    super.initState();
    _courseFuture = _apiService.fetchCourseDetails(widget.courseId);
  }


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
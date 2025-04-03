// lib/screens/course_detail/course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intellectra/views/course/models/course_models.dart';
import 'package:intellectra/views/course/services/api_service.dart';
import 'components/section_menu.dart';
import 'components/section_viewer.dart';
import 'components/navigation_buttons.dart';
import 'components/video_player_widget.dart';

class CourseDetailPage2 extends StatefulWidget {
  final int courseId;

  const CourseDetailPage2({Key? key, required this.courseId}) : super(key: key);

  @override
  _CourseDetailPageState2 createState() => _CourseDetailPageState2();
}

class _CourseDetailPageState2 extends State<CourseDetailPage2> {
  late Future<Course> _courseFuture;
  final ApiService _apiService = ApiService();
  int _currentSectionIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _courseFuture = _apiService.fetchCourseDetails(widget.courseId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // lib/screens/course_detail/course_detail_page.dart
// ... (keep imports and class definition the same)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FutureBuilder<Course>(
            future: _courseFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && 
                  snapshot.data?.pdfInternalData != null &&
                  snapshot.data?.fileType == 'pdf') {
                return IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => SectionMenu.show(
                    context,
                    snapshot.data!,
                    _currentSectionIndex,
                    _pageController,
                    (index) => setState(() => _currentSectionIndex = index),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<Course>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading course:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final course = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: course.fileType == 'video'
                    ? VideoPlayerWidget(videoUrl: course.file)
                    : SectionViewer(
                        course: course,
                        currentIndex: _currentSectionIndex,
                        pageController: _pageController,
                        onPageChanged: (index) => setState(() => _currentSectionIndex = index),
                      ),
                ),
                if (course.fileType == 'pdf')
                  NavigationButtons(
                    currentIndex: _currentSectionIndex,
                    totalSections: course.pdfInternalData?.tableOfContents.length ?? 0,
                    pageController: _pageController,
                  ),
              ],
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
// lib/screens/course_detail/course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intellectra/components/constants.dart';
import 'package:intellectra/views/course/models/course_models.dart';
import 'package:intellectra/views/course/screens/components/section_viewer.dart';
import 'package:intellectra/views/course/services/api_service.dart';
import 'components/section_menu.dart';
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
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _courseFuture = _apiService.fetchCourseDetails(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FutureBuilder<Course>(
            future: _courseFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?.pdfInternalData != null) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  onPressed:
                      () => SectionMenu.show(
                        context,
                        snapshot.data!,
                        _currentSectionIndex,
                        _pageController,
                        (index) => setState(() {
                          _currentSectionIndex =
                              index; // Update the current section index
                          _pageController.jumpToPage(
                            index,
                          ); // Jump to the selected section
                        }),
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
            final sectionCount =
                course
                    .pdfInternalData!
                    .sections
                    .length; // Get the number of sections
            print(
              'Number of sections: $sectionCount',
            ); // Debugging line to check section count
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSectionIndex =
                            index; // Update the current section index
                      });
                    },
                    itemCount: sectionCount + 1, // +1 for the video page
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // First page with video and first section
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Course Title
                              Text(
                                course.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10), // Horizontal space
                              // Course Description
                              Text(
                                course.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 20), // Space before video
                              // Video Player Section
                              VideoPlayerWidget(
                                videoUrl: course.videos ?? '',
                                onVideoPlay: () {},
                                onVideoStop: () {},
                              ),
                              const SizedBox(
                                height: 20,
                              ), // Space before section title
                              // Section Title
                              Text(
                                course.pdfInternalData!.sections[0].title,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ), // Space before content
                              // Section Content
                              Text(
                                course.pdfInternalData!.sections[0].content,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Use SectionViewer for subsequent pages
                        final section =
                            course.pdfInternalData!.sections[index -
                                1]; // Adjust index for sections
                        return SectionViewer(
                          course: course,
                          currentIndex:
                              index - 1, // Pass the correct index for sections
                          pageController:
                              _pageController, // Pass the page controller
                          onPageChanged: (newIndex) {
                            setState(() {
                              _currentSectionIndex =
                                  newIndex; // Update the current section index
                            });
                          },
                        );
                      }
                    },
                  ),
                ),
                // Navigation Buttons
                NavigationButtons(
                  currentIndex: _currentSectionIndex,
                  totalSections: sectionCount, // +1 for the video page
                  onNext: () {
                    if (_currentSectionIndex < sectionCount) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  onPrevious: () {
                    if (_currentSectionIndex > 0) {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
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

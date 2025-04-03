// lib/screens/course_detail/course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intellectra/components/constants.dart';
import 'package:intellectra/views/course/models/course_models.dart';
import 'package:intellectra/views/course/screens/components/course_info.dart';
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
  final PageController _pageController = PageController();
  bool _isVideoPlaying = false;

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
              if (snapshot.hasData && snapshot.data?.pdfInternalData != null) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  onPressed:
                      () => SectionMenu.show(
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
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged:
                        (index) => setState(() => _currentSectionIndex = index),
                    itemCount:
                        course.pdfInternalData?.tableOfContents.length ??
                        0 + 1, // +1 for the first page
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // Display both video and introduction on the first page
                        return Column(
                          children: [
                            // Introduction Section
                            CourseInfo(
                              course: course,
                            ), // Display course title and description
                            const Divider(),
                            // Video Player Sectionr
                            VideoPlayerWidget(
                              videoUrl:
                                  course.videos ?? '', // Pass the video URL
                              onVideoPlay: () {
                                setState(() {
                                  _isVideoPlaying =
                                      true; // Update state when video is playing
                                });
                              },
                              onVideoStop: () {
                                setState(() {
                                  _isVideoPlaying =
                                      false; // Update state when video is stopped
                                });
                              },
                            ),
                          ],
                        );
                      } else {
                        // Display sections for subsequent pages
                        final tocItem =
                            course.pdfInternalData!.tableOfContents[index -
                                1]; // Adjust index for sections
                        final section = course.pdfInternalData!.sections
                            .firstWhere(
                              (s) => s.order == tocItem['order'],
                              orElse:
                                  () => CourseSection(
                                    id: 0,
                                    title: '',
                                    content: '',
                                    order: -1,
                                  ),
                            );

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tocItem['title'],
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                section.content,
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
                      }
                    },
                  ),
                ),
                if (course.pdfInternalData != null)
                  NavigationButtons(
                    currentIndex: _currentSectionIndex,
                    totalSections:
                        course.pdfInternalData?.tableOfContents.length ?? 0,
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

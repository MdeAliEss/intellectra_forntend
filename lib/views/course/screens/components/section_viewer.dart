// lib/screens/course_detail/components/section_viewer.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intellectra/components/constants.dart';
import 'package:intellectra/views/course/models/course_models.dart';
import 'course_info.dart';

class SectionViewer extends StatelessWidget {
  final Course course;
  final int currentIndex;
  final PageController pageController;
  final Function(int) onPageChanged;

  const SectionViewer({
    Key? key,
    required this.course,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: course.pdfInternalData?.tableOfContents.length ?? 0,
      itemBuilder: (context, index) {
        final tocItem = course.pdfInternalData!.tableOfContents[index];
        final section = course.pdfInternalData!.sections.firstWhere(
          (s) => s.order == tocItem['order'],
          orElse: () => CourseSection(
            id: 0,
            title: '',
            content: '',
            order: -1,
          ),
        );

        String cleanTitle = tocItem['title'];
        if (cleanTitle.contains('.')) {
          cleanTitle = cleanTitle.split('.')[1].trim();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show course info only on first page
              if (index == 0) ...[
                CourseInfo(course: course),
                const Divider(),
              ],
              Text(
                cleanTitle,
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
      },
    );
  }
}
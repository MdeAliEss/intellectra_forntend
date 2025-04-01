import 'package:flutter/material.dart';
import 'package:intellectra/models/course_models.dart';
import 'package:intellectra/services/api_service.dart'; // Import your models

class CourseDetailPage extends StatefulWidget {
  final int courseId;

  const CourseDetailPage({Key? key, required this.courseId}) : super(key: key);

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late Future<Course> _courseFuture;
  final ApiService _apiService = ApiService(); // Instance of your service

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    _courseFuture = _apiService.fetchCourseDetails(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
      ),
      body: FutureBuilder<Course>(
        future: _courseFuture,
        builder: (context, snapshot) {
          // Check for errors
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

          // Check if data is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if data is available
          if (snapshot.hasData) {
            final course = snapshot.data!;
            return SingleChildScrollView( // Makes content scrollable
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display Course Title
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Display Course Description
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),

                   // Display other course info if needed (Rating, Type, etc.)
                   Row(
                     children: [
                       Icon(Icons.star, color: Colors.amber, size: 18),
                       SizedBox(width: 4),
                       Text('Rating: ${course.rating.toStringAsFixed(1)}'),
                       SizedBox(width: 16),
                       Icon(
                         course.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.videocam,
                         size: 18,
                       ),
                       SizedBox(width: 4),
                       Text('Type: ${course.fileType.toUpperCase()}'),
                     ],
                   ),
                   const SizedBox(height: 24),


                  // Display Sections Header
                  Text(
                    'Sections',
                     style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(thickness: 1), // Visual separator

                  // Display Sections List (or message if none)
                  if (course.sections.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text('No sections found for this course.')),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true, // Important inside SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                      itemCount: course.sections.length,
                      itemBuilder: (context, index) {
                        final section = course.sections[index];
                        return Card( // Use Card for better visual separation
                           margin: const EdgeInsets.symmetric(vertical: 8.0),
                           child: Padding(
                             padding: const EdgeInsets.all(12.0),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   // Display order + title
                                   '${section.order + 1}. ${section.title}', // Use order+1 for human-readable numbering
                                   style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                 ),
                                 const SizedBox(height: 6),
                                 Text(
                                   section.content,
                                   style: Theme.of(context).textTheme.bodyMedium,
                                 ),
                               ],
                             ),
                           ),
                        );
                      },
                    ),
                ],
              ),
            );
          }

          // Default case (should not happen often with FutureBuilder)
          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }
}
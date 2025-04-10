import 'package:flutter/material.dart';
import 'add_course_screen.dart'; // Import the screen to navigate to
import 'package:intellectra/views/course/models/course.dart'; // Import Course model
import 'package:intellectra/views/course/services/api_service.dart'; // Import ApiService

class ProfessorCoursesScreen extends StatefulWidget {
  final int professorId;

  const ProfessorCoursesScreen({Key? key, required this.professorId})
    : super(key: key);

  @override
  _ProfessorCoursesScreenState createState() => _ProfessorCoursesScreenState();
}

class _ProfessorCoursesScreenState extends State<ProfessorCoursesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  void _fetchCourses() {
    setState(() {
      _coursesFuture = _apiService.fetchProfessorCourses(widget.professorId);
    });
  }

  Future<void> _deleteCourse(int courseId) async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this course?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false), // Return false
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true), // Return true
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      print("Deleting course $courseId");
      try {
        await _apiService.deleteCourse(courseId); // Call the API method
        // Refresh the list after successful deletion
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Course deleted successfully')));
        _fetchCourses();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete course: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with WillPopScope to prevent popping the root screen
    return WillPopScope(
      onWillPop: () async {
        // Prevent popping if it's the first route
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Courses'),
          automaticallyImplyLeading:
              false, // Assuming this is a top-level screen after success/login
        ),
        body: FutureBuilder<List<Course>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('You have not created any courses yet.'),
              );
            }

            // Display courses in a ListView
            final courses = snapshot.data!;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  // TODO: Add course image thumbnail if available
                  // leading: course.image != null ? Image.network(course.image!, width: 50, height: 50, fit: BoxFit.cover) : null,
                  title: Text(course.title),
                  subtitle: Text(
                    course.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete Course',
                    onPressed:
                        () => _deleteCourse(course.id!), // Call delete method
                  ),
                  onTap: () {
                    // TODO: Navigate to course detail/edit screen if needed
                    print("Tapped on course: ${course.title}");
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: 'Add New Course',
          onPressed: () async {
            // Navigate to the AddCourseScreen
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                // Pass the actual professorId
                builder:
                    (context) =>
                        AddCourseScreen(professorId: widget.professorId),
              ),
            );
            // If a course was successfully added (indicated by popping with true),
            // refresh the course list.
            if (result == true) {
              _fetchCourses();
            }
          },
        ),
      ),
    );
  }
}

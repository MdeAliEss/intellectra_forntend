import 'package:flutter/material.dart';
import 'package:intellectra/components/constants.dart';
import 'package:intellectra/views/profile/profile_screen.dart';
import 'add_course_screen.dart'; // Import the screen to navigate to
import 'package:intellectra/views/course/models/course.dart'; // Import Course model
import 'package:intellectra/views/course/services/api_service.dart'; // Import ApiService
import 'professor_course_detail_screen.dart';
import 'package:intellectra/components/bottom_navigation.dart'; // Import profile screen (adjust path if needed)

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
          title: const Text(
            'My Courses',
            style: TextStyle(color: Colors.red), // Make title red
          ),
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
              padding: const EdgeInsets.all(8.0), // Add padding around the list
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0,
                    ),
                    leading: ClipRRect(
                      // Use ClipRRect for rounded corners on image
                      borderRadius: BorderRadius.circular(8.0),
                      child:
                          course.image != null
                              ? Image.network(
                                course.image ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                // Add error builder for network images
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                              )
                              : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.school,
                                  color: Colors.grey[600],
                                ),
                              ), // Placeholder icon
                    ),
                    title: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        course.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Delete Course',
                      onPressed:
                          () => _deleteCourse(course.id!), // Call delete method
                    ),
                    onTap: () {
                      // Navigate to the professor-specific detail screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ProfessorCourseDetailScreen(
                                courseId: course.id!,
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red, // Set background color to red
          foregroundColor: Colors.white, // Ensure icon is visible (white)
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // 0 for "My Courses"
          onTap: (index) {
            if (index == 1) {
              // Navigate to Profile screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const ProfileScreen(), // Using the correct class name from import
                ),
              );
            }
            // Index 0 is the current screen, so no action needed
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'My Courses',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}

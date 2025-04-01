import 'dart:convert';

// Function to decode JSON safely, especially useful if the API might return null lists
List<CourseSection> parseSections(String? responseBody) {
  if (responseBody == null || responseBody.isEmpty) return [];
  // First decode the full response to get the course data
  final courseJson = json.decode(responseBody);
  // Access the 'sections' list within the course data
  final sectionsJson = courseJson['sections'] as List<dynamic>?; // Safely access sections
  if (sectionsJson == null) return []; // Return empty if sections are null
  return sectionsJson.map((json) => CourseSection.fromJson(json)).toList();
}

Course parseCourse(String responseBody) {
    final Map<String, dynamic> parsed = json.decode(responseBody);
    return Course.fromJson(parsed);
}


class Course {
  final int id;
  final String title;
  final String description;
  final String? fileUrl; // Assuming file field gives a URL or path
  final String? imageUrl;
  final String fileType;
  final double rating;
  final List<CourseSection> sections;
  // Add other fields from your Course model as needed

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.fileUrl,
    this.imageUrl,
    required this.fileType,
    required this.rating,
    required this.sections,
     // Initialize other fields
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Handle potentially null sections list
    var sectionsList = <CourseSection>[];
    if (json['sections'] != null && json['sections'] is List) {
      sectionsList = (json['sections'] as List)
          .map((sectionJson) => CourseSection.fromJson(sectionJson))
          .toList();
    }

    return Course(
      id: json['id'] ?? 0, // Provide default value if null
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      fileUrl: json['file'], // Might be null
      imageUrl: json['image'], // Might be null
      fileType: json['file_type'] ?? 'unknown',
      rating: (json['rating'] ?? 0.0).toDouble(), // Ensure it's a double
      sections: sectionsList,
      // Parse other fields
    );
  }
}

class CourseSection {
  final int id;
  final String title;
  final String content;
  final int order;

  CourseSection({
    required this.id,
    required this.title,
    required this.content,
    required this.order,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      content: json['content'] ?? 'No Content',
      order: json['order'] ?? 0,
    );
  }
}
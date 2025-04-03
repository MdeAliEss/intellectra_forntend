import 'package:http/http.dart' as http;
import 'package:intellectra/views/course/models/course_models.dart';
import 'dart:convert'; // Add this import for JSON parsing
import 'dart:io';

class ApiService {
  static const String _baseUrl = "http://127.0.0.1:8000/";

  Future<Course> fetchCourseDetails(int courseId) async {
    final String url = '$_baseUrl/courses/api/courses/$courseId/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Course.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Course not found (404)');
      } else {
        throw Exception('Failed to load course (Status code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Network Error: Failed to connect to the server.');
    } on HttpException {
      throw Exception('HTTP Error: Could not find the resource.');
    } on FormatException {
      throw Exception('Format Error: Bad response format from server.');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}
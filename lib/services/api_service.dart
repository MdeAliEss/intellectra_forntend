import 'package:http/http.dart' as http;
import 'package:intellectra/models/course_models.dart';
import 'dart:convert';
import 'dart:io'; // For HttpException// Import your models

class ApiService {
  // --- IMPORTANT: Replace with your actual IP/domain ---
  // Use 10.0.2.2 for Android Emulator accessing localhost on the host machine
  // Use your machine's network IP if testing on a physical device on the same network
  static const String _baseUrl = "http://127.0.0.1:8000/"; // Or your IP: "http://192.168.1.100:8000"

  Future<Course> fetchCourseDetails(int courseId) async {
    final String url = '$_baseUrl/courses/api/courses/$courseId/'; // Adjust path if needed

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the server returns an OK response, parse the JSON.
        // Use the compute function or Isolate for heavy parsing if needed
        return parseCourse(response.body);
      } else if (response.statusCode == 404) {
         throw Exception('Course not found (404)');
      }
      else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to load course (Status code: ${response.statusCode})');
      }
    } on SocketException {
       throw Exception('Network Error: Failed to connect to the server.');
    } on HttpException {
       throw Exception('HTTP Error: Could not find the resource.');
    } on FormatException {
       throw Exception('Format Error: Bad response format from server.');
    }
     catch (e) {
       throw Exception('An unknown error occurred: $e');
    }
  }
}
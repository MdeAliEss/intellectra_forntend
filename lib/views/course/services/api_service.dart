import 'package:http/http.dart' as http;
import 'package:intellectra/views/course/models/course_models.dart';
import 'dart:convert'; // Add this import for JSON parsing
import 'dart:io';

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:8000/";

  Future<Course> fetchCourseDetails(int courseId) async {
    final String url = '$_baseUrl/courses/api/courses/$courseId/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Log the JSON response for debugging
        print('Response JSON: ${response.body}');

        // Parse the JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Handle video URL for Android
        if (jsonData['videos'] != null) {
          String videoUrl = jsonData['videos'];
          // If the video URL is relative, make it absolute
          if (!videoUrl.startsWith('http')) {
            videoUrl = '$_baseUrl$videoUrl';
          }
          // Replace localhost with 10.0.2.2 for Android emulator
          videoUrl = videoUrl.replaceAll('localhost', '10.0.2.2');
          jsonData['videos'] = videoUrl;
        }

        return Course.fromJson(jsonData);
      } else {
        // Log the response body for debugging
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to load course (Status code: ${response.statusCode})',
        );
      }
    } on SocketException {
      throw Exception('Network Error: Failed to connect to the server.');
    } on HttpException {
      throw Exception('HTTP Error: Could not find the resource.');
    } on FormatException {
      throw Exception('Format Error: Bad response format from server.');
    } catch (e) {
      // Log the error for debugging
      print('An unknown error occurred: $e');
      throw Exception('An unknown error occurred: $e');
    }
  }
}

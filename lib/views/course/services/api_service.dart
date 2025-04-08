import 'package:http/http.dart' as http;
import 'package:intellectra/views/course/models/course_models.dart';
import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:8000/";

  Future<Course> fetchCourseDetails(int courseId) async {
    final String url = '$_baseUrl/courses/api/courses/$courseId/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response JSON: ${response.body}');

        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Fix video URL for Android
        if (jsonData['videos'] != null) {
          String videoUrl = jsonData['videos'];
          if (!videoUrl.startsWith('http')) {
            videoUrl = '$_baseUrl$videoUrl';
          }
          videoUrl = videoUrl.replaceAll('localhost', '10.0.2.2');
          jsonData['videos'] = videoUrl;
        }

        // ✅ Debug log for quiz fields
        print('Quiz - question: ${jsonData['question']}');
        print('Quiz - answer: ${jsonData['answer']}');
        print('Quiz - correct_answer: ${jsonData['correct_answer']}');

        return Course.fromJson(jsonData);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load course (Status code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Network Error: Failed to connect to the server.');
    } on HttpException {
      throw Exception('HTTP Error: Could not find the resource.');
    } on FormatException {
      throw Exception('Format Error: Bad response format from server.');
    } catch (e) {
      print('An unknown error occurred: $e');
      throw Exception('An unknown error occurred: $e');
    }
  }
}

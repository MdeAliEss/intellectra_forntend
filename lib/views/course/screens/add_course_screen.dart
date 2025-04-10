import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Models
import '../models/category.dart';
import '../models/quiz.dart';
import '../models/course.dart';

// Services
import '../services/api_service.dart';

// Components
import 'components/text_field_component.dart';
import 'components/file_picker_component.dart';
import 'components/category_selector_component.dart';
import 'components/quiz_input_component.dart';
import 'components/add_quiz_button.dart';

// Import the success screen
import 'course_success_screen.dart';

class AddCourseScreen extends StatefulWidget {
  final int professorId; // <-- Replace with actual professor ID

  const AddCourseScreen({Key? key, required this.professorId})
    : super(key: key);

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers for text fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _ratingController = TextEditingController();

  // State variables for selected files
  File? _pdfFile;
  File? _videoFile;
  File? _imageFile;

  // State variable for selected category ID
  int? _selectedCategoryId;

  // State variable for list of quizzes
  // Use a Map to easily update quizzes by index
  Map<int, Quiz> _quizzesMap = {};
  int _nextQuizKey = 0; // To assign unique keys for adding/removing

  // State variables for loading and errors
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _addQuiz() {
    setState(() {
      // Add an empty placeholder; QuizInputComponent will handle the actual Quiz object creation
      // The key doesn't necessarily map 1:1 to the final list index
      _quizzesMap[_nextQuizKey] = Quiz(
        question: '',
        answers: ['', ''],
        correctAnswerIndex: 0,
      ); // Initial empty state
      _nextQuizKey++;
    });
  }

  void _removeQuiz(int key) {
    setState(() {
      _quizzesMap.remove(key);
    });
  }

  void _updateQuiz(int key, Quiz quiz) {
    // Update the quiz in the map
    // No setState needed here if QuizInputComponent handles its own state
    // and _submitForm reads directly from the map
    _quizzesMap[key] = quiz;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Additional validation for non-FormField widgets
      bool isQuizDataValid = true;
      if (_quizzesMap.isEmpty) {
        // Optional: require at least one quiz?
      } else {
        // Validate each quiz in the map
        for (var quiz in _quizzesMap.values) {
          if (quiz.question.isEmpty ||
              quiz.answers.length < 2 ||
              quiz.answers.any((a) => a.isEmpty) ||
              quiz.correctAnswerIndex < 0 ||
              quiz.correctAnswerIndex >= quiz.answers.length) {
            isQuizDataValid = false;
            break;
          }
        }
      }

      if (_selectedCategoryId == null) {
        setState(() {
          _errorMessage = 'Please select a category.';
        });
        return;
      }
      if (!isQuizDataValid) {
        setState(() {
          _errorMessage =
              'Please ensure all quiz fields are filled correctly and each quiz has a selected correct answer.';
        });
        return;
      }
      // At least one file (PDF or Video) should be selected
      if (_pdfFile == null && _videoFile == null) {
        setState(() {
          _errorMessage =
              'Please select either a PDF document or a Video file.';
        });
        return;
      }
      // Image is optional based on your model, but if required, add check here
      // if (_imageFile == null) {
      //     setState(() {
      //        _errorMessage = 'Please select a course image.';
      //     });
      //     return;
      // }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final List<Quiz> quizzesList = _quizzesMap.values.toList();
        final double initialRating =
            double.tryParse(_ratingController.text) ?? 0.0; // Parse rating

        final createdCourse = await _apiService.createCourse(
          _titleController.text,
          _descriptionController.text,
          _durationController.text,
          initialRating, // <-- Pass parsed rating
          _selectedCategoryId!, // We already validated it's not null
          widget.professorId, // Use the professorId from the widget
          quizzesList,
          pdfFile: _pdfFile,
          videoFile: _videoFile,
          imageFile: _imageFile,
        );

        setState(() {
          _isLoading = false;
        });

        // Navigate to the success screen, removing the AddCourseScreen from the stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    AddCourseSuccessScreen(professorId: widget.professorId),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to create course: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // --- Basic Course Info ---
              TextFieldComponent(
                controller: _titleController,
                labelText: 'Course Title',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a title'
                            : null,
              ),
              TextFieldComponent(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 4,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a description'
                            : null,
              ),
              TextFieldComponent(
                controller: _durationController,
                labelText: 'Duration (e.g., 2h 30m)',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter the duration'
                            : null,
              ),
              TextFieldComponent(
                controller: _ratingController,
                labelText: 'Initial Rating (0.0 - 5.0)',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an initial rating';
                  }
                  final rating = double.tryParse(value);
                  if (rating == null) {
                    return 'Please enter a valid number';
                  }
                  if (rating < 0.0 || rating > 5.0) {
                    return 'Rating must be between 0.0 and 5.0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- File Pickers ---
              FilePickerComponent(
                labelText: 'PDF Document (Optional)',
                fileType: FileType.custom,
                allowedExtensions: ['pdf'],
                selectedFile: _pdfFile,
                onFileSelected: (file) => setState(() => _pdfFile = file),
              ),
              FilePickerComponent(
                labelText: 'Video File (Optional)',
                fileType: FileType.video,
                // allowedExtensions: ['mp4', 'mov', 'avi'], // Add specific types if needed
                selectedFile: _videoFile,
                onFileSelected: (file) => setState(() => _videoFile = file),
              ),
              FilePickerComponent(
                labelText: 'Course Image (Optional)',
                fileType: FileType.image,
                selectedFile: _imageFile,
                onFileSelected: (file) => setState(() => _imageFile = file),
              ),
              const SizedBox(height: 16),

              // --- Category Selector ---
              CategorySelectorComponent(
                onCategorySelected: (categoryId) {
                  // Need setState only if using the value directly in build,
                  // but it's good practice to keep state updated.
                  setState(() {
                    _selectedCategoryId = categoryId;
                  });
                },
                // initialCategoryId: null, // Set if editing
              ),
              const SizedBox(height: 24),

              // --- Quizzes Section ---
              Text("Quizzes", style: Theme.of(context).textTheme.headlineSmall),
              const Divider(),
              if (_quizzesMap.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      "No quizzes added yet. Click 'Add Quiz' below.",
                    ),
                  ),
                ),
              ..._quizzesMap.entries.map((entry) {
                int key = entry.key;
                // Pass initialQuiz only if needed for editing, not for new ones
                // Quiz initialData = entry.value;
                return QuizInputComponent(
                  key: ValueKey(key), // Important for list state management
                  quizIndex: _quizzesMap.keys.toList().indexOf(
                    key,
                  ), // Display index
                  // initialQuiz: initialData, // Pass if supporting editing existing quiz
                  onQuizChanged: (quiz) => _updateQuiz(key, quiz),
                  onRemove: () => _removeQuiz(key),
                );
              }).toList(),
              AddQuizButton(onPressed: _addQuiz),

              const SizedBox(height: 32),
              // --- Submit Button ---
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : _submitForm, // Disable button while loading
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Create Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Quiz {
  String question;
  List<String> answers;
  int correctAnswerIndex; // Index of the correct answer in the 'answers' list

  Quiz({
    required this.question,
    required this.answers,
    required this.correctAnswerIndex,
  }) {
    // Basic validation
    if (answers.length < 2) {
      throw ArgumentError('A quiz must have at least two answers.');
    }
    if (correctAnswerIndex < 0 || correctAnswerIndex >= answers.length) {
      throw ArgumentError('Correct answer index is out of bounds.');
    }
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    // Ensure answers is a list of strings
    var answersFromJson = json['answers'];
    List<String> answersList;
    if (answersFromJson is List) {
      answersList = List<String>.from(
        answersFromJson.map((item) => item.toString()),
      );
    } else {
      answersList =
          []; // Handle case where answers might be missing or not a list
    }

    // Ensure correct_answer is an int
    var correctIndexFromJson = json['correct_answer'];
    int correctIndex;
    if (correctIndexFromJson is int) {
      correctIndex = correctIndexFromJson;
    } else if (correctIndexFromJson is String) {
      correctIndex =
          int.tryParse(correctIndexFromJson) ??
          0; // Default to 0 if parse fails
    } else {
      correctIndex = 0; // Default or error handling
    }

    // Basic validation on loaded data
    if (answersList.length < 2) {
      // Handle invalid data - perhaps log an error or use default values
      print("Warning: Quiz loaded with less than 2 answers.");
      answersList.addAll(
        List.filled(2 - answersList.length, 'Placeholder Answer'),
      ); // Add placeholders
    }
    if (correctIndex < 0 || correctIndex >= answersList.length) {
      print("Warning: Quiz loaded with invalid correct answer index.");
      correctIndex = 0; // Reset to a safe default
    }

    return Quiz(
      question:
          json['question']?.toString() ?? '', // Provide default empty string
      answers: answersList,
      correctAnswerIndex: correctIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answers': answers,
      'correct_index': correctAnswerIndex, // Change key to correct_index
    };
  }
}

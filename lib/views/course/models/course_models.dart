class Course {
  final int id;
  final String title;
  final String description;
  final String file;
  final String? image;
  final String fileType;
  final String duration;
  final double rating;
  final DateTime createdAt;
  final int professor;
  final int category;
  final PdfInternalData? pdfInternalData;  // Add this field

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.file,
    this.image,
    required this.fileType,
    required this.duration,
    required this.rating,
    required this.createdAt,
    required this.professor,
    required this.category,
    this.pdfInternalData,  // Add this
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      file: json['file'],
      image: json['image'],
      fileType: json['file_type'],
      duration: json['duration'],
      rating: json['rating'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      professor: json['professor'],
      category: json['category'],
      pdfInternalData: json['pdf_internal_data'] != null 
          ? PdfInternalData.fromJson(json['pdf_internal_data'])
          : null,
    );
  }
}

class PdfInternalData {
  final int id;
  final String name;
  final List<dynamic> tableOfContents;
  final List<CourseSection> sections;

  PdfInternalData({
    required this.id,
    required this.name,
    required this.tableOfContents,
    required this.sections,
  });

  factory PdfInternalData.fromJson(Map<String, dynamic> json) {
    return PdfInternalData(
      id: json['id'],
      name: json['name'],
      tableOfContents: json['table_of_contents'],
      sections: (json['sections'] as List)
          .map((section) => CourseSection.fromJson(section))
          .toList(),
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
      id: json['id'],
      title: json['title'],
      content: json['content'],
      order: json['order'],
    );
  }
}
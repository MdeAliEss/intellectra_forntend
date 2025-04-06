// lib/screens/course_detail/components/section_menu.dart
import 'package:flutter/material.dart';
import 'package:intellectra/views/course/models/course_models.dart';

class SectionMenu {
  static void show(
    BuildContext context,
    Course course,
    int currentIndex,
    PageController pageController,
    Function(int) onIndexChanged,
  ) {
    final tableOfContents = course.pdfInternalData.tableOfContents ?? [];
    final sections = course.pdfInternalData.sections ?? [];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Table of Contents',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tableOfContents.length,
                  itemBuilder: (context, index) {
                    final tocItem = tableOfContents[index];
                    String cleanTitle = tocItem['title'];
                    if (cleanTitle.contains('.')) {
                      cleanTitle = cleanTitle.split('.')[1].trim();
                    }

                    return ListTile(
                      title: Text(cleanTitle),
                      leading: Text('${index + 1}'),
                      selected: index == currentIndex,
                      onTap: () {
                        pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        onIndexChanged(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

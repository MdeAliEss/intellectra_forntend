// lib/screens/course_detail/components/section_menu.dart
import 'package:flutter/material.dart';
// Ensure these paths are correct for your project structure
import 'package:intellectra/views/course/models/course_models.dart';
import 'package:intellectra/components/constants.dart'; // Assuming you use this for primaryColor

class SectionMenu {
  static void show(
    BuildContext context,
    Course course,
    int currentVisiblePageIndex, // Pass the current index of the PageView
    PageController pageController,
    Function(int) onPageSelected, // Callback accepting the target PageView index
  ) {
    // Use the sections list as the primary source for menu items
    final sections = course.pdfInternalData.sections ?? [];
    // Check if the course actually has quizzes
    final bool hasQuizzes = course.quizzes.isNotEmpty;

    // Total items in the menu = number of sections + 1 for Quiz (if it exists)
    final int totalMenuItems = sections.length + (hasQuizzes ? 1 : 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow modal to take more height if needed
      shape: const RoundedRectangleBorder( // Optional: Add rounded top corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          // Set a max height to prevent covering the whole screen
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make column height adapt to content
            children: [
              // --- Menu Header ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Course Content', // Or course.title
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 1, thickness: 1), // Visual separator

              // --- Scrollable Menu Items ---
              Flexible( // Use Flexible + shrinkWrap for ListView in Column
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: totalMenuItems,
                  itemBuilder: (context, index) {
                    // Determine the target PageView index for this menu item.
                    // Menu index corresponds directly to PageView index here.
                    int targetPageIndex = index;

                    bool isSelected = (targetPageIndex == currentVisiblePageIndex);
                    String title;
                    Widget leadingWidget;

                    // --- Build Section Item ---
                    if (index < sections.length) {
                      // Get title from the section data
                      title = sections[index].title;
                      // Create leading widget (e.g., numbered circle)
                      leadingWidget = CircleAvatar(
                        radius: 14,
                        backgroundColor: isSelected ? primaryColor : Colors.grey.shade300,
                        foregroundColor: isSelected ? Colors.white : Colors.black54,
                        // Displaying index + 1 for user-friendly numbering (1, 2, 3...)
                        child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      );
                    }
                    // --- Build Quiz Item (only if quizzes exist and index is the last one) ---
                    else if (hasQuizzes && index == sections.length) {
                      title = 'Quizzes';
                      // Create leading widget (e.g., icon)
                      leadingWidget = CircleAvatar(
                        radius: 14,
                        backgroundColor: isSelected ? primaryColor : Colors.grey.shade300,
                        foregroundColor: isSelected ? Colors.white : Colors.black54,
                        child: const Icon(Icons.quiz_outlined, size: 16),
                      );
                      // Ensure targetPageIndex is correctly set to sections.length
                      targetPageIndex = sections.length;
                      // Re-check selection based on correct quiz page index
                      isSelected = (targetPageIndex == currentVisiblePageIndex);
                    }
                    // --- Fallback (shouldn't normally be reached) ---
                    else {
                      return const SizedBox.shrink(); // Render nothing if index is unexpected
                    }

                    // --- Create the ListTile ---
                    return ListTile(
                      leading: leadingWidget,
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primaryColor : null, // Highlight selected item text
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: isSelected,
                      // Use theme's selection color or define your own
                      // selectedTileColor: primaryColor.withOpacity(0.08),
                      onTap: () {
                        // Animate the PageView to the target page index
                        pageController.animateToPage(
                          targetPageIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        // Notify the parent widget about the page change
                        onPageSelected(targetPageIndex);
                        // Close the bottom sheet
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
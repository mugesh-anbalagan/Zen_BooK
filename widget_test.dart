import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import your main application file
// NOTE: I'm assuming your main file is named 'main.dart'
import 'package:zen_book/main.dart'; 

void main() {
  // Define the main group for the test suite
  group('BookList Widget Tests', () {

    // Helper function to build and pump the app widget
    Future<void> pumpBookApp(WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      // Wait for the widgets to be built, necessary for the initial list to appear
      await tester.pumpAndSettle(); 
    }

    // --- Test 1: Initial State and Display Verification ---
    testWidgets('Displays initial list of books and app title', (WidgetTester tester) async {
      await pumpBookApp(tester);

      // Verify the AppBar title
      expect(find.text('Advanced Book Manager'), findsOneWidget);

      // Verify the initial books are displayed
      expect(find.text('Dune'), findsOneWidget);
      expect(find.text('Frank Herbert'), findsOneWidget);
      expect(find.text('Sapiens'), findsOneWidget);
      
      // Verify the Floating Action Button is present
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add New Book'), findsOneWidget);
    });

    // --- Test 2: FAB Functionality (Adding a New Book) ---
    testWidgets('FAB adds a new book to the list', (WidgetTester tester) async {
      await pumpBookApp(tester);

      // Initially, the hardcoded new book title should NOT be present
      expect(find.text('A New Sci-Fi Adventure'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(3)); // 3 initial books

      // Tap the FAB to add a book
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(); // Start the animation/rebuild
      await tester.pump(const Duration(milliseconds: 500)); // Complete the build

      // Verify the new book has appeared
      expect(find.text('A New Sci-Fi Adventure'), findsOneWidget);
      expect(find.text('A. Flutter Dev'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(4)); // Should now have 4 books

      // Verify the SnackBar confirmation appears
      expect(find.text('Book added!'), findsOneWidget);
    });

    // --- Test 3: Dismissible Functionality (Deleting a Book) ---
    testWidgets('Swiping a list item removes the book and shows UNDO option', (WidgetTester tester) async {
      await pumpBookApp(tester);

      // Find the first book's ListTile
      final bookToDismiss = find.widgetWithText(ListTile, 'Dune');
      expect(bookToDismiss, findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3)); 

      // Perform a swipe gesture to dismiss the item (right to left)
      await tester.drag(bookToDismiss, const Offset(-500.0, 0.0));
      await tester.pumpAndSettle(); // Wait for the dismissal animation to complete

      // Verify the book is removed from the list
      expect(find.text('Dune'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(2)); 

      // Verify the SnackBar with UNDO action is displayed
      expect(find.text('Dune removed.'), findsOneWidget);
      final undoButton = find.text('UNDO');
      expect(undoButton, findsOneWidget);

      // Tap UNDO
      await tester.tap(undoButton);
      await tester.pumpAndSettle(); // Wait for the UNDO action to complete

      // Verify the book is re-inserted
      expect(find.text('Dune'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    // --- Test 4: Edit Dialog Interaction ---
    testWidgets('Tapping a book opens the edit dialog', (WidgetTester tester) async {
      await pumpBookApp(tester);

      // Tap on the 'Sapiens' list item
      await tester.tap(find.text('Sapiens'));
      await tester.pumpAndSettle(); // Wait for the dialog to open

      // Verify the AlertDialog is displayed
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Edit Book Details'), findsOneWidget);
      
      // Verify that the book's current title is pre-filled in a TextField
      expect(find.widgetWithText(TextField, 'Sapiens'), findsOneWidget);
      
      // Close the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      
      // Verify the dialog is gone
      expect(find.byType(AlertDialog), findsNothing);
    });

  });
}
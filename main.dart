import 'package:flutter/material.dart';

// --- 1. Book Model Class (Updated with Description) ---
enum ReadingStatus { toRead, reading, finished }

class Book {
  final String title;
  final String author;
  final String description; // NEW FEATURE: Book Description
  final ReadingStatus status;

  const Book({
    required this.title,
    required this.author,
    this.description = 'No description provided.', // Default
    this.status = ReadingStatus.toRead,
  });

  // Helper method to create a copy with new values (useful for editing)
  Book copyWith({String? title, String? author, String? description, ReadingStatus? status}) {
    return Book(
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}

// --- Main Application Structure (Unchanged) ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Book Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(secondary: Colors.deepOrangeAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const BookList(),
    );
  }
}

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  // Initial list of books with descriptions
  final List<Book> _books = [
    const Book(
      title: 'Dune',
      author: 'Frank Herbert',
      description: 'A masterpiece of science fiction and fantasy, set on the desert planet Arrakis.',
      status: ReadingStatus.finished,
    ),
    const Book(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      description: 'A brief history of humankind.',
      status: ReadingStatus.reading,
    ),
    const Book(
      title: 'The Lord of the Rings',
      author: 'J.R.R. Tolkien',
      description: 'The epic high-fantasy novel following the hobbit Frodo Baggins.',
      status: ReadingStatus.toRead,
    ),
  ];

  String _sortCriteria = 'Title';

  // --- Helper methods for UI (Icon, Color) ---
  IconData _getStatusIcon(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.toRead:
        return Icons.bookmark_add;
      case ReadingStatus.reading:
        return Icons.menu_book;
      case ReadingStatus.finished:
        return Icons.check_circle;
    }
  }

  Color _getStatusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.toRead:
        return Colors.blueGrey;
      case ReadingStatus.reading:
        return Colors.amber.shade700;
      case ReadingStatus.finished:
        return Colors.green;
    }
  }

  // --- Sorting Logic (Unchanged) ---
  void _sortBooks(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      if (criteria == 'Title') {
        _books.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      } else if (criteria == 'Author') {
        _books.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
      } else if (criteria == 'Status') {
        _books.sort((a, b) => a.status.index.compareTo(b.status.index));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sorted by $criteria')),
    );
  }

  // --- Function to add a new book (Updated for description) ---
  void _addBook() {
    const newBook = Book(
      title: 'New Fantasy Novel',
      author: 'A. Code Contributor',
      description: 'A dynamically added book with a default description.',
      status: ReadingStatus.toRead,
    );
    setState(() {
      _books.add(newBook);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book added: New Fantasy Novel')),
    );
  }

  // --- NEW FEATURE: Function to delete a book ---
  void _deleteBook(int index) {
    final Book deletedBook = _books[index];
    setState(() {
      _books.removeAt(index);
    });

    // Show undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedBook.title} removed.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _books.insert(index, deletedBook); // Re-insert the book
            });
          },
        ),
      ),
    );
  }

  // --- Function to edit a book (Unchanged) ---
  void _editBook(int index, Book updatedBook) {
    setState(() {
      _books[index] = updatedBook;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${updatedBook.title} updated.')),
    );
  }

  // --- Edit Dialog UI (Updated for Description) ---
  Future<void> _showEditDialog(int index) async {
    final book = _books[index];
    final TextEditingController titleController = TextEditingController(text: book.title);
    final TextEditingController authorController = TextEditingController(text: book.author);
    // NEW: Controller for Description
    final TextEditingController descriptionController = TextEditingController(text: book.description);
    ReadingStatus selectedStatus = book.status;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Book Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                // NEW FEATURE: Description TextField
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setStateInner) {
                    return DropdownButtonFormField<ReadingStatus>(
                      decoration: const InputDecoration(labelText: 'Status'),
                      value: selectedStatus,
                      items: ReadingStatus.values.map((ReadingStatus status) {
                        return DropdownMenuItem<ReadingStatus>(
                          value: status,
                          child: Text(status.toString().split('.').last.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (ReadingStatus? newValue) {
                        if (newValue != null) {
                          setStateInner(() {
                            selectedStatus = newValue;
                          });
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                final updatedBook = Book(
                  title: titleController.text,
                  author: authorController.text,
                  // NEW: Pass description to the updated Book
                  description: descriptionController.text,
                  status: selectedStatus,
                );
                _editBook(index, updatedBook);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Book Manager'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _sortBooks,
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext context) {
              return {'Title', 'Author', 'Status'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text('Sort by $choice'),
                );
              }).toList();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          
          // Using a Dismissible widget for the swipe-to-delete functionality
          return Dismissible(
            key: Key(book.title + book.author + index.toString()), 
            direction: DismissDirection.startToEnd, // Change swipe direction for visual clarity
            background: Container(
              color: Colors.red.shade700,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete_sweep, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteBook(index); // Use the existing delete logic
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 2,
              child: ListTile(
                leading: Icon(_getStatusIcon(book.status), color: _getStatusColor(book.status), size: 28),
                title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                // Displaying the description as the subtitle now
                subtitle: Text(
                  book.description, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, // Ensures professional look on long text
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display status text
                    Text(
                      book.status.toString().split('.').last,
                      style: TextStyle(color: _getStatusColor(book.status), fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    // NEW FEATURE: Dedicated Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () => _deleteBook(index),
                    ),
                  ],
                ),
                onTap: () => _showEditDialog(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(_books.length), // Re-using the edit dialog to add a new book
        icon: const Icon(Icons.add),
        label: const Text('Add New Book'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.black,
      ),
    );
  }
}
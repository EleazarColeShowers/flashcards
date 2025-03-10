import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FlashcardsPage extends StatefulWidget {
  final String topic;
  const FlashcardsPage({required this.topic, Key? key}) : super(key: key);

  @override
  _FlashcardsPageState createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, String>> _flashcards = [];
  final PageController _pageController = PageController();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFlashcards();
  }

  void _fetchFlashcards() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "User not logged in.";
        });
        return;
      }

      _database.child("users").child(user.uid).child("flashcards").child(widget.topic).onValue.listen((event) {
        final snapshot = event.snapshot.value as Map<dynamic, dynamic>?;

        if (snapshot == null) {
          setState(() {
            _flashcards = [];
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _flashcards = snapshot.entries.map((entry) {
            final data = Map<String, dynamic>.from(entry.value as Map);
            return {
              "question": data["question"]?.toString() ?? "No question",
              "answer": data["answer"]?.toString() ?? "No answer"
            };
          }).toList();
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load flashcards: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5E1),
      appBar: AppBar(title: Text(widget.topic)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _flashcards.isEmpty
                  ? Center(child: Text("No flashcards available"))
                  : PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _flashcards.length,
                      itemBuilder: (context, index) {
                        return FlashcardWidget(
                          question: _flashcards[index]["question"]!,
                          answer: _flashcards[index]["answer"]!,
                        );
                      },
                    ),
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final String question;
  final String answer;

  const FlashcardWidget({required this.question, required this.answer, Key? key}) : super(key: key);

  @override
  _FlashcardWidgetState createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFlipped = !isFlipped;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(turns: animation, child: child);
        },
        child: Container(
          key: ValueKey<bool>(isFlipped),
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            color: isFlipped ? const Color(0xFFB3E5FC) : const Color(0xFFFFD1DC),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              isFlipped ? widget.answer : widget.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

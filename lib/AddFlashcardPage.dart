import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddFlashcardPage extends StatefulWidget {
  @override
  _AddFlashcardPageState createState() => _AddFlashcardPageState();
}

class _AddFlashcardPageState extends State<AddFlashcardPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _database;
  List<String> _topics = [];

  @override
  void initState() {
    super.initState();
    _setDatabaseReference();
    _fetchTopics();
  }

  void _setDatabaseReference() {
    final User? user = _auth.currentUser;
    if (user != null) {
      _database = FirebaseDatabase.instance.ref().child('users').child(user.uid).child('flashcards');
    }
  }

  void _fetchTopics() {
    _database.onValue.listen((event) {
      final snapshot = event.snapshot.value as Map<dynamic, dynamic>?;
      if (snapshot != null) {
        setState(() {
          _topics = snapshot.keys.cast<String>().toList();
        });
      }
    });
  }

  void _saveFlashcard() {
    String topic = _topicController.text.trim();
    String question = _questionController.text.trim();
    String answer = _answerController.text.trim();

    if (topic.isNotEmpty && question.isNotEmpty && answer.isNotEmpty) {
      _database.child(topic).push().set({
        "question": question,
        "answer": answer,
      }).then((_) {
        print("Flashcard added successfully!");
        Navigator.pop(context);
      }).catchError((error) {
        print("Error adding flashcard: $error");
      });

      if (!_topics.contains(topic)) {
        setState(() {
          _topics.add(topic);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5E1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopicField(),
              SizedBox(height: 20),
              TextField(
                controller: _questionController,
                decoration: InputDecoration(labelText: "Question"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(labelText: "Answer"),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4A0E5C)),
                onPressed: _saveFlashcard,
                child: Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _topicController,
          decoration: InputDecoration(
            labelText: "Enter Topic or Select from List",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Select Topic",
            border: OutlineInputBorder(),
          ),
          items: _topics.map((topic) {
            return DropdownMenuItem<String>(
              value: topic,
              child: Text(topic),
            );
          }).toList(),
          onChanged: (selectedTopic) {
            setState(() {
              _topicController.text = selectedTopic!;
            });
          },
        ),
      ],
    );
  }
}

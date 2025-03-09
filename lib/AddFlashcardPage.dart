import 'package:flutter/material.dart';

class AddFlashcardPage extends StatefulWidget {
  @override
  _AddFlashcardPageState createState() => _AddFlashcardPageState();
}

class _AddFlashcardPageState extends State<AddFlashcardPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4A0E5C),
        title: Text("Add Flashcard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
              onPressed: () {
                String question = _questionController.text;
                String answer = _answerController.text;

                if (question.isNotEmpty && answer.isNotEmpty) {
                  Navigator.pop(context, {"question": question, "answer": answer});
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

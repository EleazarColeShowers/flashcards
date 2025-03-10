import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'FlashcardPage.dart';
import 'AddFlashcardPage.dart';
import 'main.dart'; 

class HomePage extends StatefulWidget {
  
  final bool justLoggedIn;

  const HomePage({super.key, this.justLoggedIn = false});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _database;
  List<String> _topics = [];
  String _username = "User"; // Default username

  @override
  void initState() {
    super.initState();
    _setDatabaseReference();
  }

void _setDatabaseReference() {
  final User? user = _auth.currentUser;
  if (user != null) {
    _database = FirebaseDatabase.instance.ref().child('users').child(user.uid);

    // Fetch username first
    _database.child("username").once().then((event) {
      final username = event.snapshot.value as String?;
      if (username != null) {
        setState(() {
          _username = username;
        });

        // Show the dialog *after* fetching the username
        if (widget.justLoggedIn) {
          Future.delayed(Duration(milliseconds: 500), () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.pink[50],
                  title: Text(
                    "Hey, $_username! 😊",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                  content: Text(
                    "I hope you have a wonderful day! 🌸\n\n- From El",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Thanks!", style: TextStyle(color: Colors.purple, fontSize: 16)),
                    ),
                  ],
                );
              },
            );
          });
        }
      }
    });

    // Fetch topics
    _database.child("flashcards").onValue.listen((event) {
      final snapshot = event.snapshot.value as Map<dynamic, dynamic>?;
      if (snapshot != null) {
        setState(() {
          _topics = snapshot.keys.cast<String>().toList();
        });
      }
    });
  }
}

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login page
    );
  }

  void _deleteTopic(String topic) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Topic"),
          content: Text("Are you sure you want to delete this topic?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _database.child("flashcards").child(topic).remove();
                Navigator.of(context).pop();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5E1),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Logout button positioned in the top-right corner
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.logout, color: Colors.red, size: 28),
                onPressed: _logout,
              ),
            ),
            Text(
              "Hey, $_username, ready to ace your exams?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.pink,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "Select a Topic",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A0E5C)),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _topics.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardsPage(topic: _topics[index]),
                        ),
                      );
                    },
                    onLongPress: () => _deleteTopic(_topics[index]),
                    child: Card(
                      color: Color(0xFF4A0E5C),
                      child: Center(
                        child: Text(
                          _topics[index],
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF4A0E5C),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFlashcardPage()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'AddFlashcardPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  List<Map<String, String>> _flashcards = [
    {"question": "What is Flutter?", "answer": "Flutter is an open-source UI toolkit."},
    {"question": "What is Dart?", "answer": "Dart is a programming language for Flutter."},
    {"question": "Stateful vs Stateless?", "answer": "Stateful widgets have mutable state."},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addFlashcard() async {
    final newFlashcard = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFlashcardPage()),
    );

    if (newFlashcard != null) {
      setState(() {
        _flashcards.add({
          "question": newFlashcard["question"],
          "answer": newFlashcard["answer"],
        });
      });

      Future.delayed(Duration(milliseconds: 500), () {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_flashcards.length - 1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: CurvedBottomClipper(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  color: const Color(0xFF4A0E5C),
                ),
              ),
            ],
          ),
          Expanded(
            child: PageView.builder(
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
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home,
                  color: _selectedIndex == 0 ? const Color(0xFF4A0E5C) : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.person,
                  color: _selectedIndex == 1 ? const Color(0xFF4A0E5C) : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A0E5C),
        shape: const CircleBorder(),
        onPressed: _addFlashcard,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
            color: Colors.purple[200],
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
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

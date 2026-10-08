import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thamizhi_keyboard/thamizhi_keyboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thamizhi Keyboard Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF6B4EE6), // A sleek purple accent
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6B4EE6),
          secondary: Color(0xFF03DAC6),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _isKeyboardVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    _focusNode.unfocus();
    setState(() {
      _isKeyboardVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thamizhi Keyboard"),
        actions: [
          if (_isKeyboardVisible)
            IconButton(
              icon: const Icon(Icons.keyboard_hide_rounded),
              onPressed: _hideKeyboard,
              tooltip: 'Hide Keyboard',
            ),
        ],
      ),
      body: GestureDetector(
        onTap: _hideKeyboard,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Text
                        Text(
                          "Experience fast and responsive Tamil typing.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(230),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "A modern, production-ready keyboard SDK for Flutter.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withAlpha(150),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Premium Input Field Container
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withAlpha(_focusNode.hasFocus ? 30 : 0),
                                blurRadius: 30,
                                spreadRadius: -5,
                              ),
                            ],
                            border: Border.all(
                              color: _focusNode.hasFocus
                                  ? Theme.of(context).primaryColor
                                  : Colors.white.withAlpha(30),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            readOnly:
                                true, // using true so we only show our keyboard
                            showCursor: true, // Keep the cursor blinking
                            autofocus: true,
                            maxLines: null,
                            minLines: 3,
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 22,
                              color: Colors.white,
                              height: 1.6,
                            ),
                            cursorColor: Theme.of(context).primaryColor,
                            cursorWidth: 3,
                            cursorRadius: const Radius.circular(2),
                            decoration: InputDecoration(
                              hintText: "Type something in Tamil...",
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(80),
                                fontSize: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Custom Keyboard Area
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              height: _isKeyboardVisible ? null : 0,
              child: _isKeyboardVisible
                  ? ThamizhiKeyboard(
                      controller: _textController,
                      // Desktop / wide web windows get the full-size keyboard.
                      fontFamily: GoogleFonts.notoSansTamil().fontFamily,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

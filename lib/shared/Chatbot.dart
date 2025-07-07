import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // Initialize the Generative Model
  GenerativeModel? _model;
  String? _initError;

  @override
  void initState() {
    super.initState();
    // Add a small delay to ensure dotenv is loaded from main.dart
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeModel();
    });
  }

  void _initializeModel() {
    try {
      final geminiApiKey = dotenv.env['geminiapi'];
      print('Attempting to get API key...');
      print('API Key exists: ${geminiApiKey != null}');
      print('API Key length: ${geminiApiKey?.length ?? 0}');
      
      if (geminiApiKey == null || geminiApiKey.isEmpty) {
        setState(() {
          _initError = 'Gemini API key not found in .env file. Please check your .env file contains: geminiapi=YOUR_API_KEY';
        });
        return;
      }
      
      // Initialize the model with the API key from .env - using gemini-1.5-flash instead of gemini-pro
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiApiKey,
      );
      
      print('Model initialized successfully');
    } catch (e) {
      print('Error initializing model: $e');
      setState(() {
        _initError = 'Failed to initialize AI model: ${e.toString()}';
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_initError ?? 'AI model not initialized')),
      );
      return;
    }

    String message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"user": message});
      _isLoading = true;
    });
    _controller.clear();

    try {
      // Simplified prompt for better compatibility
      final prompt = 'You are an agricultural expert. Answer this farming question briefly and practically: $message';
      
      print('Sending request to Gemini API...');
      final content = Content.text(prompt);
      
      // Add timeout to the request
      final response = await _model!.generateContent([content]).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection.');
        },
      );
      
      print('Response received from Gemini API');
      setState(() {
        _messages.add({"bot": response.text ?? "I couldn't process that request. Please try again."});
        _isLoading = false;
      });
    } catch (e) {
      print('Detailed error: $e');
      print('Error type: ${e.runtimeType}');
      
      String errorMessage;
      if (e.toString().contains('Failed to fetch') || e.toString().contains('ClientException')) {
        errorMessage = "Network error. Please check your internet connection and try again.";
      } else if (e.toString().contains('timeout')) {
        errorMessage = "Request timed out. Please check your connection and try again.";
      } else if (e.toString().contains('API key')) {
        errorMessage = "Invalid API key. Please check your Gemini API key.";
      } else if (e.toString().contains('403')) {
        errorMessage = "API access forbidden. Please check your API key permissions.";
      } else if (e.toString().contains('429')) {
        errorMessage = "Too many requests. Please wait and try again.";
      } else {
        errorMessage = "Connection error: ${e.toString()}";
      }
      
      setState(() {
        _messages.add({"bot": errorMessage});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Agri Assistant'),
          backgroundColor: Colors.green[400],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                'Error: $_initError',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initError = null;
                  });
                  _initializeModel();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 40, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.green[400],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.smart_toy, color: Colors.black, size: 30),
                SizedBox(width: 20),
                Text(
                  "Agri Assistant",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          // Chatbot messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      "Ask your agriculture questions\nabout crops, weather, pests, or soil",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      bool isUser = _messages[index].containsKey("user");
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.green[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isUser ? _messages[index]["user"]! : _messages[index]["bot"]!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Input Field & Send Button
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about crops, weather, pests...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF4A6B3E)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
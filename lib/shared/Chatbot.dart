import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _userType;
  String? _userName;

  // Initialize the Generative Model
  GenerativeModel? _model;

  @override
  void initState() {
    super.initState();
    _initializeModel();
    _loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    try {
      final geminiApiKey = dotenv.env['geminiapi'];
      if (geminiApiKey == null || geminiApiKey.isEmpty) {
        setState(() {
          _messages.add({"bot": "Error: AI service is not configured properly. Please contact support."});
        });
        return;
      }
      
      // Initialize the model with the API key from .env
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiApiKey,
      );
    } catch (e) {
      setState(() {
        _messages.add({"bot": "Error initializing AI service: ${e.toString()}"});
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userType = prefs.getString('user_type');
        _userName = prefs.getString('user_name') ?? prefs.getString('user_email');
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isEmpty || _model == null) return;

    setState(() {
      _messages.add({"user": message});
      _isLoading = true;
    });
    _controller.clear();

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      // Create a specialized prompt based on user type
      String contextPrompt = _buildContextPrompt(message);
      
      final content = Content.text(contextPrompt);
      final response = await _model!.generateContent([content]);
      
      setState(() {
        _messages.add({"bot": response.text ?? "I couldn't process that request. Please try again."});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({"bot": "Error: Unable to get response. Please check your internet connection and try again."});
        _isLoading = false;
      });
      print('Chatbot error: $e');
    }

    // Auto-scroll to bottom after response
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _buildContextPrompt(String message) {
    String userContext = _userType == 'farmer' ? 
      'You are helping a farmer' : 
      _userType == 'shopowner' ? 
        'You are helping a shop owner who deals with agricultural products' : 
        'You are helping someone interested in agriculture';
    
    return '''
    You are an expert agricultural assistant. $userContext.
    
    Guidelines:
    - Provide practical, actionable advice in simple language
    - Focus on crop management, pest control, weather impact, soil health, and farming techniques
    - If helping a shop owner, also include advice on crop storage, quality assessment, and market trends
    - Keep responses concise but informative (2-3 paragraphs max)
    - Use bullet points for lists when appropriate
    - If the question isn't agriculture-related, politely redirect to farming topics
    - Always be encouraging and supportive
    
    User's question: $message
    
    Please provide a helpful response:
    ''';
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                const Icon(Icons.smart_toy, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                const Text(
                  "Agri Assistant",
                  style: TextStyle(
                    color: Colors.white,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 80,
                          color: Colors.green[300],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Welcome to Agri Assistant!",
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Ask me about:\n• Crop management\n• Pest control\n• Weather impacts\n• Soil health\n• Farming techniques",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text("Thinking..."),
                              ],
                            ),
                          ),
                        );
                      }
                      bool isUser = _messages[index].containsKey("user");
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.green[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: isUser ? Border.all(color: Colors.green[300]!, width: 1) : null,
                          ),
                          child: Text(
                            isUser ? _messages[index]["user"]! : _messages[index]["bot"]!,
                            style: TextStyle(
                              fontSize: 16,
                              color: isUser ? Colors.green[800] : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Input Field & Send Button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Ask about crops, weather, pests...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
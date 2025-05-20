import 'package:flutter/material.dart';
import 'package:mobile_ui/services/chatbot_service.dart'; // A ChatbotService importálása

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  final ChatbotService _chatbotService = ChatbotService();

  void _sendMessage() async {
    final userInput = _controller.text;
    if (userInput.isNotEmpty) {
      setState(() {
        _messages.add('You: $userInput');
      });
      _controller.clear();
      
      try {
        final response = await _chatbotService.getChatResponse(userInput);
        setState(() {
          _messages.add('Chatbot: $response');
        });
      } catch (e) {
        setState(() {
          _messages.add('Chatbot: Error occurred');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // Zárja be a chatbot oldalt
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_messages[index]),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

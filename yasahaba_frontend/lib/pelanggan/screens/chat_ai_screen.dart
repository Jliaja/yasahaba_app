import 'package:flutter/material.dart';
import '../services/pelanggan_service.dart';

class ChatMessage {
  final String sender;
  final String text;
  ChatMessage({required this.sender, required this.text});
}

class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  final _msgController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      sender: 'ai',
      text: 'Halo! Saya Asisten AI Yasahaba. Ada kendala dengan WiFi rumah (PPPoE/Hotspot) atau mau tanya tagihan?',
    ),
  ];
  bool _isTyping = false;

  Future<void> _kirimPesan() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(sender: 'user', text: text));
      _isTyping = true;
    });
    _msgController.clear();

    final reply = await PelangganService().askGeminiAi(text);

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(sender: 'ai', text: reply));
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asisten AI Yasahaba'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUser = _messages[index].sender == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _messages[index].text,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(alignment: Alignment.centerLeft, child: Text('Asisten AI sedang mengecek data...', style: TextStyle(fontSize: 12, color: Colors.grey))),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(hintText: 'Tanya kendala wifi / tagihan...', border: InputBorder.none),
                    onSubmitted: (_) => _kirimPesan(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.indigo), onPressed: _isTyping ? null : _kirimPesan),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
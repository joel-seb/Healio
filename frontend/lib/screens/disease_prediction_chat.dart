import 'package:flutter/material.dart';
import '../widgets/page_header.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class DiseasePredictionChat extends StatefulWidget {
  const DiseasePredictionChat({super.key});

  @override
  State<DiseasePredictionChat> createState() => _DiseasePredictionChatState();
}

class _DiseasePredictionChatState extends State<DiseasePredictionChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  final _api = ApiService();

  String get _userInitials {
    final name = AuthService().userData?.name ?? '';
    if (name.trim().isEmpty) return '?';
    return name.trim().split(' ')
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .take(2)
        .join();
  }

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      ChatMessage(
        text: "Hi! I'm your AI Health Assistant. Describe your symptoms and I'll help identify possible conditions.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
      ChatMessage(
        text: "⚠️ Preliminary AI tool only. For accurate diagnosis, consult a healthcare professional.",
        isUser: false,
        timestamp: DateTime.now(),
        isWarning: true,
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isSending = true;
    });
    _messageController.clear();
    _scrollToBottom();

    String response;
    try {
      response = await _api.sendChatMessage(text);
    } catch (e) {
      response = "⚠️ Could not reach the health assistant. Please check your connection and try again.";
    }

    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
      _isSending = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const PageHeader(
            title: 'Health Assistant',
            icon: Icons.chat_bubble_outline,
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),
          if (_isSending)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  SizedBox(width: 16),
                  SizedBox(width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF20B2AA))),
                  SizedBox(width: 8),
                  Text('Thinking…', style: TextStyle(fontSize: 12, color: Color(0xFF20B2AA))),
                ],
              ),
            ),
          _buildInputRow(context),
        ],
      ),
    );
  }

  Widget _buildInputRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Type your symptoms here…',
                  hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 14),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2D3748)
                      : const Color(0xFFF0F4F8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: Color(0xFF20B2AA), width: 1.5)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isSending ? Colors.grey.shade300 : const Color(0xFF20B2AA),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = message.isWarning
        ? (isDark ? const Color(0xFF2D2010) : const Color(0xFFFFF4E5))
        : message.isUser
            ? const Color(0xFF20B2AA)
            : (isDark ? const Color(0xFF2D3748) : Colors.white);

    final textColor = message.isWarning
        ? (isDark ? const Color(0xFFFFCC80) : const Color(0xFF7A4F00))
        : message.isUser
            ? Colors.white
            : Theme.of(context).textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar on the LEFT
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF20B2AA), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              margin: message.isUser
                  ? const EdgeInsets.only(left: 56)
                  : const EdgeInsets.only(right: 56),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: message.isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                border: message.isWarning
                    ? Border.all(color: const Color(0xFFFFB74D), width: 1)
                    : !message.isUser
                        ? Border.all(color: Theme.of(context).dividerColor, width: 1)
                        : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),

          // User initials avatar on the RIGHT
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF20B2AA).withOpacity(0.15),
                border: Border.all(color: const Color(0xFF20B2AA), width: 1.5),
              ),
              child: Center(
                child: Text(
                  _userInitials,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF20B2AA),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isWarning;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isWarning = false,
  });
}

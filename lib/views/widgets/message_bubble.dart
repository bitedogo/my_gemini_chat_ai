import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/chat_message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final timeFormat = DateFormat('HH:mm');

    if (message.isTyping) {
      return _buildTypingIndicator();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : const LinearGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser ? const Color(0xFF667eea) : Colors.black).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeFormat.format(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(isUser),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isUser
            ? const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        )
            : const LinearGradient(
          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isUser ? const Color(0xFF667eea) : const Color(0xFFF093FB)).withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          isUser ? 'ME' : 'AI',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(200),
                const SizedBox(width: 4),
                _buildDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.white70,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .then()
        .fadeOut(duration: 600.ms);
  }
}
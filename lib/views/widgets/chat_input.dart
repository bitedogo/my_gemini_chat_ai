import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    required this.isLoading,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _hasText = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  void _handleSend() {
    if (_hasText && !widget.isLoading) {
      widget.onSend(_controller.text);
      _controller.clear();
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() => _isListening = false);
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_controller.text.trim().isNotEmpty) {
                _handleSend();
              }
            });
          } else if (status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('음성 인식 오류: ${error.errorMsg}')),
          );
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
          localeId: 'ko_KR',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('음성 인식을 사용할 수 없습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            _buildMicButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isListening
                        ? const Color(0xFF667eea)
                        : Colors.white.withOpacity(0.1),
                    width: _isListening ? 2 : 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _handleSend(),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: _isListening
                        ? '듣는 중...'
                        : '말하거나 입력해서 Gemini에게 질문하기',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _isListening
            ? const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
        )
            : LinearGradient(
          colors: [
            const Color(0xFF667eea).withOpacity(0.3),
            const Color(0xFF764ba2).withOpacity(0.3),
          ],
        ),
        boxShadow: _isListening
            ? [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : _toggleListening,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: (_hasText && !widget.isLoading)
            ? const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [
            Colors.grey[700]!,
            Colors.grey[800]!,
          ],
        ),
        boxShadow: (_hasText && !widget.isLoading)
            ? [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleSend,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Icon(
              Icons.send_rounded,
              color: (_hasText && !widget.isLoading)
                  ? Colors.white
                  : Colors.grey[600],
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';

/// Ultra-smooth word streaming text optimized for performance
class SmoothStreamingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration wordDelay;

  const SmoothStreamingText({
    super.key,
    required this.text,
    required this.style,
    this.wordDelay = const Duration(milliseconds: 100),
  });

  @override
  State<SmoothStreamingText> createState() => _SmoothStreamingTextState();
}

class _SmoothStreamingTextState extends State<SmoothStreamingText> {
  List<String> _words = [];
  int _visibleWordCount = 0;
  Timer? _wordTimer;
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    _initializeText();
  }

  @override
  void didUpdateWidget(SmoothStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text && widget.text != _lastText) {
      _initializeText();
    }
  }

  void _initializeText() {
    if (widget.text.isEmpty) return;
    
    _lastText = widget.text;
    _words = widget.text.split(' ').where((word) => word.isNotEmpty).toList();
    _visibleWordCount = 0;
    
    // Cancel existing timer
    _wordTimer?.cancel();
    
    // Start word animation
    _startWordAnimation();
  }

  void _startWordAnimation() {
    if (_words.isEmpty) return;

    _wordTimer = Timer.periodic(widget.wordDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_visibleWordCount < _words.length) {
        setState(() {
          _visibleWordCount++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_visibleWordCount == 0) {
      return Text('', style: widget.style);
    }

    final displayText = _words.take(_visibleWordCount).join(' ');
    
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 150),
      style: widget.style,
      child: Text(displayText),
    );
  }
}
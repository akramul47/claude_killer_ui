import 'package:flutter/material.dart';

class StreamingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration animationDuration;

  const StreamingText({
    super.key,
    required this.text,
    required this.style,
    this.animationDuration = const Duration(milliseconds: 50),
  });

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds: widget.text.length * widget.animationDuration.inMilliseconds,
      ),
      vsync: this,
    );

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final displayText = widget.text.substring(0, _characterCount.value);
        return Text(
          displayText,
          style: widget.style,
        );
      },
    );
  }
}

// Word-by-word streaming text with fade-in effect like Microsoft Copilot
class WordStreamingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration wordDelay;

  const WordStreamingText({
    super.key,
    required this.text,
    required this.style,
    this.wordDelay = const Duration(milliseconds: 80),
  });

  @override
  State<WordStreamingText> createState() => _WordStreamingTextState();
}

class _WordStreamingTextState extends State<WordStreamingText>
    with SingleTickerProviderStateMixin {
  List<String> _words = [];
  int _visibleWordCount = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    
    print('🔤 WordStreamingText: Starting animation for "${widget.text}" (${_words.length} words)');
    
    _controller = AnimationController(
      duration: Duration(
        milliseconds: _words.length * widget.wordDelay.inMilliseconds,
      ),
      vsync: this,
    );

    _startWordAnimation();
  }

  void _startWordAnimation() {
    for (int i = 0; i < _words.length; i++) {
      Future.delayed(Duration(milliseconds: i * widget.wordDelay.inMilliseconds), () {
        if (mounted) {
          setState(() {
            _visibleWordCount = i + 1;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(_visibleWordCount, (index) {
        return TweenAnimationBuilder<double>(
          key: ValueKey(index),
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 5),
              child: Opacity(
                opacity: value,
                child: Text(
                  '${_words[index]} ',
                  style: widget.style,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class FadeInText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration delay;
  final Duration duration;

  const FadeInText({
    super.key,
    required this.text,
    required this.style,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<FadeInText> createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}

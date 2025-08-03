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

// Ultra-reliable streaming text with smooth animation
class WordStreamingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration wordDelay;

  const WordStreamingText({
    super.key,
    required this.text,
    required this.style,
    this.wordDelay = const Duration(milliseconds: 120), // Slower for smoother animation
  });

  @override
  State<WordStreamingText> createState() => _WordStreamingTextState();
}

class _WordStreamingTextState extends State<WordStreamingText> 
    with SingleTickerProviderStateMixin {
  String _currentText = '';
  List<String> _words = [];
  int _currentWordIndex = 0;
  bool _isAnimating = false;
  bool _isAnimationComplete = false;
  String _lastProcessedText = '';
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(WordStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only restart animation if the text has actually changed
    if (oldWidget.text != widget.text && widget.text.isNotEmpty && widget.text != _lastProcessedText) {
      _isAnimationComplete = false;
      _initializeAnimation();
    }
  }

  void _initializeAnimation() {
    if (widget.text.isEmpty) {
      setState(() {
        _currentText = '';
      });
      return;
    }

    // If animation is already complete and text hasn't changed, don't restart
    if (_isAnimationComplete && widget.text == _lastProcessedText) {
      return;
    }

    _words = widget.text.split(' ').where((word) => word.isNotEmpty).toList();
    _currentWordIndex = 0;
    _currentText = '';
    _isAnimating = true;
    _lastProcessedText = widget.text;
    
    print('🔤 WordStreamingText: Animating "${widget.text}" (${_words.length} words)');
    _animateNextWord();
  }

  void _animateNextWord() {
    if (!mounted || !_isAnimating || _currentWordIndex >= _words.length) {
      _isAnimating = false;
      _isAnimationComplete = true;
      return;
    }

    final word = _words[_currentWordIndex];
    final isFirstWord = _currentWordIndex == 0;
    final newText = isFirstWord ? word : '$_currentText $word';

    if (mounted) {
      setState(() {
        _currentText = newText;
      });
    }

    _currentWordIndex++;
    
    // Add slight randomness for more natural feel, but keep it smooth
    final baseDelay = widget.wordDelay.inMilliseconds;
    final randomVariation = ((_currentWordIndex % 3) * 10); // Small variation
    final delay = baseDelay + randomVariation;
    
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted && _isAnimating) {
        _animateNextWord();
      }
    });
  }

  @override
  void dispose() {
    _isAnimating = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If animation is complete, show the full text without animation for performance
    if (_isAnimationComplete) {
      return Text(
        widget.text,
        style: widget.style,
      );
    }

    // During animation, show the current animated text with smooth effects
    final displayText = _currentText.isEmpty && widget.text.isNotEmpty 
        ? '' // Show nothing until animation starts
        : _currentText;
        
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: widget.style,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 150),
        tween: Tween<double>(begin: 0.9, end: 1.0),
        curve: Curves.easeOutQuart,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Text(
                displayText,
                style: widget.style,
              ),
            ),
          );
        },
      ),
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

// Simple typewriter effect as backup
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration delay;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.delay = const Duration(milliseconds: 50),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    if (_currentIndex < widget.text.length) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _displayText = widget.text.substring(0, _currentIndex);
          });
          _startTyping();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
    );
  }
}

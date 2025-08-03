import 'package:flutter/material.dart';

class SmoothStreamingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration characterDelay;
  final Duration fadeInDuration;

  const SmoothStreamingText({
    super.key,
    required this.text,
    required this.style,
    this.characterDelay = const Duration(milliseconds: 30),
    this.fadeInDuration = const Duration(milliseconds: 200),
  });

  @override
  State<SmoothStreamingText> createState() => _SmoothStreamingTextState();
}

class _SmoothStreamingTextState extends State<SmoothStreamingText>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  List<AnimationController> _charControllers = [];
  List<Animation<double>> _charAnimations = [];
  int _currentCharIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: Duration(
        milliseconds: widget.text.length * widget.characterDelay.inMilliseconds,
      ),
      vsync: this,
    );

    _initializeCharacterAnimations();
    _startAnimation();
  }

  void _initializeCharacterAnimations() {
    for (int i = 0; i < widget.text.length; i++) {
      final controller = AnimationController(
        duration: widget.fadeInDuration,
        vsync: this,
      );
      
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      _charControllers.add(controller);
      _charAnimations.add(animation);
    }
  }

  void _startAnimation() {
    _animateNextCharacter();
  }

  void _animateNextCharacter() {
    if (_currentCharIndex < _charControllers.length) {
      _charControllers[_currentCharIndex].forward();
      _currentCharIndex++;
      
      Future.delayed(widget.characterDelay, () {
        if (mounted) {
          _animateNextCharacter();
        }
      });
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    for (final controller in _charControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: List.generate(widget.text.length, (index) {
          return WidgetSpan(
            child: AnimatedBuilder(
              animation: _charAnimations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _charAnimations[index].value) * 10),
                  child: Opacity(
                    opacity: _charAnimations[index].value,
                    child: Text(
                      widget.text[index],
                      style: widget.style,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

// Simple word-by-word streaming text
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
  late AnimationController _controller;
  List<String> _words = [];
  int _visibleWords = 0;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    
    _controller = AnimationController(
      duration: Duration(
        milliseconds: _words.length * widget.wordDelay.inMilliseconds,
      ),
      vsync: this,
    );

    _startAnimation();
  }

  void _startAnimation() {
    for (int i = 0; i < _words.length; i++) {
      Future.delayed(Duration(milliseconds: i * widget.wordDelay.inMilliseconds), () {
        if (mounted) {
          setState(() {
            _visibleWords = i + 1;
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
      children: List.generate(_visibleWords, (index) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 20),
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

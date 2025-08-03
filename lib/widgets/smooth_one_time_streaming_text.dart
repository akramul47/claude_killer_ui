import 'package:flutter/material.dart';

class SmoothOneTimeStreamingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration characterDelay;
  final Duration fadeInDuration;
  final VoidCallback? onCompleted;

  const SmoothOneTimeStreamingText({
    super.key,
    required this.text,
    required this.style,
    this.characterDelay = const Duration(milliseconds: 80),
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.onCompleted,
  });

  @override
  State<SmoothOneTimeStreamingText> createState() => _SmoothOneTimeStreamingTextState();
}

class _SmoothOneTimeStreamingTextState extends State<SmoothOneTimeStreamingText>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  List<AnimationController> _charControllers = [];
  List<Animation<double>> _charAnimations = [];
  int _currentCharIndex = 0;
  bool _isAnimationComplete = false;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _previousText = widget.text;
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(SmoothOneTimeStreamingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only animate if text changed and animation isn't complete
    if (oldWidget.text != widget.text && !_isAnimationComplete) {
      // If text is getting longer (streaming), continue animation
      if (widget.text.length > _previousText.length && 
          widget.text.startsWith(_previousText)) {
        _previousText = widget.text;
        _addNewCharacters(oldWidget.text.length);
      } else {
        // If completely different text, restart animation
        _previousText = widget.text;
        _restartAnimation();
      }
    }
  }

  void _initializeAnimation() {
    _mainController = AnimationController(
      duration: Duration(
        milliseconds: widget.text.length * widget.characterDelay.inMilliseconds,
      ),
      vsync: this,
    );

    _initializeCharacterAnimations();
    _startAnimation();
  }

  void _addNewCharacters(int startIndex) {
    // Add controllers for new characters
    for (int i = startIndex; i < widget.text.length; i++) {
      final controller = AnimationController(
        duration: widget.fadeInDuration,
        vsync: this,
      );
      
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutQuart,
      ));

      _charControllers.add(controller);
      _charAnimations.add(animation);
    }

    // Continue animation from where we left off
    _continueAnimation(startIndex);
  }

  void _restartAnimation() {
    // Dispose old controllers
    for (final controller in _charControllers) {
      controller.dispose();
    }
    _charControllers.clear();
    _charAnimations.clear();
    _currentCharIndex = 0;
    _isAnimationComplete = false;

    _initializeAnimation();
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
        curve: Curves.easeOutQuart,
      ));

      _charControllers.add(controller);
      _charAnimations.add(animation);
    }
  }

  void _startAnimation() {
    _animateNextCharacter();
  }

  void _continueAnimation(int startIndex) {
    _currentCharIndex = startIndex;
    _animateNextCharacter();
  }

  void _animateNextCharacter() {
    if (_currentCharIndex < _charControllers.length && !_isAnimationComplete) {
      _charControllers[_currentCharIndex].forward();
      _currentCharIndex++;
      
      if (_currentCharIndex >= _charControllers.length) {
        _isAnimationComplete = true;
        widget.onCompleted?.call();
      } else {
        Future.delayed(widget.characterDelay, () {
          if (mounted) {
            _animateNextCharacter();
          }
        });
      }
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
    // If animation is complete, show regular text for performance
    if (_isAnimationComplete) {
      return Text(
        widget.text,
        style: widget.style,
      );
    }

    // Otherwise show animated text
    return Wrap(
      children: List.generate(widget.text.length, (index) {
        if (index >= _charAnimations.length) {
          return Text(
            widget.text[index],
            style: widget.style.copyWith(
              color: widget.style.color?.withOpacity(0.0),
            ),
          );
        }
        
        return AnimatedBuilder(
          animation: _charAnimations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - _charAnimations[index].value) * 6), // Gentle slide up
              child: Opacity(
                opacity: _charAnimations[index].value,
                child: Text(
                  widget.text[index],
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

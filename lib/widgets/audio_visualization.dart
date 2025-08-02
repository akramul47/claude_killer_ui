import 'package:flutter/material.dart';
import '../painters/audio_wave_painter.dart';

class AudioVisualization extends StatefulWidget {
  final bool isActive;
  final AnimationController backgroundController;

  const AudioVisualization({
    super.key,
    required this.isActive,
    required this.backgroundController,
  });

  @override
  State<AudioVisualization> createState() => _AudioVisualizationState();
}

class _AudioVisualizationState extends State<AudioVisualization>
    with TickerProviderStateMixin {
  late AnimationController _primaryWaveController;
  late AnimationController _secondaryWaveController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    _primaryWaveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _secondaryWaveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _primaryWaveController.dispose();
    _secondaryWaveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Ensure transparent background
      child: CustomPaint(
        painter: AudioWavePainter(
          primaryAnimation: _primaryWaveController,
          secondaryAnimation: _secondaryWaveController,
          pulseAnimation: _pulseController,
          isActive: widget.isActive,
        ),
        size: Size.infinite,
      ),
    );
  }
}

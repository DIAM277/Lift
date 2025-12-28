import 'dart:async';
import 'package:flutter/material.dart';

class RestTimerOverlay extends StatefulWidget {
  final int durationInSeconds;
  final VoidCallback onComplete;

  const RestTimerOverlay({
    super.key,
    this.durationInSeconds = 120, // 默认2分钟
    required this.onComplete,
  });

  @override
  State<RestTimerOverlay> createState() => _RestTimerOverlayState();
}

class _RestTimerOverlayState extends State<RestTimerOverlay>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationInSeconds;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _pulseController.stop();
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 脉动的图标
            ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.1).animate(
                CurvedAnimation(
                  parent: _pulseController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F75FF).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer,
                  size: 64,
                  color: Color(0xFF4F75FF),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "组间休息",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // 倒计时显示
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 48),
            // 跳过按钮
            OutlinedButton(
              onPressed: () {
                _timer?.cancel();
                _pulseController.stop();
                widget.onComplete();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "跳过休息",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

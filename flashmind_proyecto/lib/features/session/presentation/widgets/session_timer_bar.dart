import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class SessionTimerBar extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;

  const SessionTimerBar({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  double get _progress => secondsRemaining / totalSeconds;

  Color get _barColor {
    if (_progress > 0.5) return AppColors.correct;
    if (_progress > 0.2) return AppColors.warning;
    return AppColors.incorrect;
  }

  String get _timeLabel {
    final m = secondsRemaining ~/ 60;
    final s = secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: 4,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.surface2,
                  valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _timeLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _barColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

enum BookingStatus { pending, active, completed, disputed }

class StatusPill extends StatelessWidget {
  final BookingStatus status;

  const StatusPill({super.key, required this.status});

  Color _getColor() {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.statusPending;
      case BookingStatus.active:
        return AppColors.statusActive;
      case BookingStatus.completed:
        return AppColors.statusCompleted;
      case BookingStatus.disputed:
        return AppColors.statusDisputed;
    }
  }

  String _getText() {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.disputed:
        return 'Disputed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        _getText(),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

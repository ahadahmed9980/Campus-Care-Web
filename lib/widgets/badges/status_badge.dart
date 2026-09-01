import 'package:flutter/material.dart';

class StatusBadge extends StatefulWidget {
  final String status;
  const StatusBadge({required this.status, super.key});

  @override
  State<StatusBadge> createState() => StatusBadgeState();
}

class StatusBadgeState extends State<StatusBadge> {
  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (widget.status.trim().toLowerCase()) {
      'in progress' => (const Color(0xFFFFF3E0), const Color(0xFFFB8C00)),
      'under review' => (const Color(0xFFE3F2FD), const Color(0xFF1E88E5)),
      'resolved' => (const Color(0xFFE8F5E9), const Color(0xFF43A047)),
      'rejected' => (const Color(0xFFFFEBEE), const Color(0xFFE53935)),
      'submitted' => (const Color(0xFFECEFF1), const Color(0xFF546E7A)),
      _ => (const Color(0xFFF5F5F5), const Color(0xFF757575)),
    };

    return Container(
      width: 75,
      height: 28,
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        widget.status,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

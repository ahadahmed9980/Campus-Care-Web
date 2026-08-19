import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppDialog extends StatelessWidget {
  final String title;
  final Widget child; // Yahan aap apna Form/Column pass karenge
  final double maxWidth;
  final VoidCallback? onClose;

  const CustomAppDialog({
    super.key,
    required this.title,
    required this.child,
    this.maxWidth = 480,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: onClose ?? () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Body (Form, Column, etc.)
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
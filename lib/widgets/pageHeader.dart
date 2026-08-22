import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget widget;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    final constraints = MediaQuery.sizeOf(context);
    final isMobile = constraints.width < 600;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: isMobile
                ? textTheme.headlineMedium
                : textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          if (isMobile) ...[
            Text(
              subtitle,
              style: textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            widget,
          ] else ...[
            Row(
              children: [
                Text(
                  subtitle,
                  style: textTheme.labelLarge,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: widget,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
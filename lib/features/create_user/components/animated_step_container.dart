// lib/widgets/animated_step_container.dart
import 'package:flutter/material.dart';

class AnimatedStepContainer extends StatelessWidget {
  final Widget child;

  const AnimatedStepContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: Container(
          key: ValueKey(child.hashCode),
          constraints: const BoxConstraints(maxWidth: 370),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(blurRadius: 16, color: Colors.black.withOpacity(.04))],
          ),
          child: child,
        ),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}
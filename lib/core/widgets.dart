import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.onPressed, required this.label, this.icon});
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (icon != null) ...[
          Icon(icon), const SizedBox(width: 8),
        ],
        Text(label),
      ]),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800));
  }
}

class DotChips extends StatelessWidget {
  const DotChips({super.key, required this.count, required this.current});
  final int count;
  final int current;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 8, width: i == current ? 22 : 8,
        decoration: BoxDecoration(
          color: i == current ? Theme.of(context).colorScheme.primary : Colors.white24,
          borderRadius: BorderRadius.circular(99),
        ),
      )),
    );
  }
}
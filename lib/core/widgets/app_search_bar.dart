import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_text_field.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search ...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 40,
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(200)),
      child: AppTextField(
        controller: controller,
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodySmall,
        contentPadding:
            const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 12),
        borderRadius: BorderRadius.circular(200),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(200),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: Icon(Icons.search, color: AppColors.secondary, size: 20),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

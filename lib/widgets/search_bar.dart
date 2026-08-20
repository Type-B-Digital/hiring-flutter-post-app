import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:post_app/app_config.dart';
import 'package:post_app/provider/post_provider.dart';

class PostSearchField extends StatefulWidget {
  const PostSearchField({super.key});

  @override
  State<PostSearchField> createState() => _PostSearchFieldState();
}

class _PostSearchFieldState extends State<PostSearchField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    //cancel any prev debounce timer
    _debounce?.cancel();
    //set debounde on evey key stroke
    _debounce = Timer(Duration(milliseconds: AppConfig.searchDebounceMs), () {
      context.read<PostProvider>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: _onChanged,
      decoration: const InputDecoration(
        hintText: 'Search posts...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

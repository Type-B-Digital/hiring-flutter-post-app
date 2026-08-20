import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/post.dart';

class FeaturedPostCard extends StatelessWidget {
  final Post post;

  const FeaturedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 261.78,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary1,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Text('📖', style: TextStyle(fontSize: 24)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Text('👤', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        post.authorName ?? 'User ${post.userId}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 16),
                      const Text('❤️', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '${post.reactions}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:post_app/provider/post_provider.dart';
import 'package:post_app/utils/app_theme.dart';

class PostDetailsScreen extends StatelessWidget {
  final int id;

  const PostDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final post = context.watch<PostProvider>().getById(id);
    final theme = Theme.of(context);

    if (post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Post not found.')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: AppColors.primary1,
            foregroundColor: Colors.white,
            flexibleSpace: const FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.loginGradient),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (post.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: post.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 20, color: AppColors.critical),
                      const SizedBox(width: 6),
                      Text('${post.likes} likes', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 20),
                      const Icon(Icons.thumb_down_alt_rounded, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text('${post.dislikes} dislikes', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 20),
                      const Icon(Icons.visibility_rounded, size: 20, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text('${post.views} views', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    post.body,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
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

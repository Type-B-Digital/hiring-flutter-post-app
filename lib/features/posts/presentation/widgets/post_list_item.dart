import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/post.dart';

class PostListItem extends StatelessWidget {
  final Post post;

  const PostListItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342,
      height: 203,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        post.authorName != null
                            ? (post.authorName!.length > 1
                                ? post.authorName!.substring(0, 2).toUpperCase()
                                : post.authorName!.toUpperCase())
                            : '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              height: 1,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.authorName ?? '',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.darkText,
                            letterSpacing: 0,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  post.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF666666),
                        letterSpacing: 0,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${post.reactions}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 16),
                    const Text('💬', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${post.views}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 16),
                    const Text('🕒', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '2h ago',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:postsapp/core/constants/app_colors.dart';
import 'package:postsapp/core/constants/app_text_styles.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/core/injection/injector.dart';
import 'package:postsapp/features/posts/domain/post_model.dart';
import 'package:postsapp/features/posts/domain/post_repository.dart';

class PostDetailScreen extends StatelessWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: Text('Post Details', style: AppTextStyles.titleBold),
      ),
      body: FutureBuilder<Result<PostModel>>(
        future: sl<PostsRepository>().getPostById(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final result = snapshot.data;

          if (result == null) {
            return const Center(child: Text('Something went wrong'));
          }
          return switch (result) {
            Success(:final data) => _PostDetailContent(post: data),
            Error(:final failure) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  failure.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.footnoteRegular,
                ),
              ),
            ),
          };
        },
      ),
    );
  }
}

class _PostDetailContent extends StatelessWidget {
  final PostModel post;
  const _PostDetailContent({required this.post});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title, style: AppTextStyles.titleBold),
          const SizedBox(height: 12),
          _buildStatsRow(),
          const SizedBox(height: 20),
          _buildTags(),
          const SizedBox(height: 20),
          Text(
            post.body,
            style: AppTextStyles.footnoteRegular.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        const Icon(Icons.favorite, size: 16, color: AppColors.critical),
        const SizedBox(width: 4),
        Text('${post.reactions.likes}', style: AppTextStyles.footnoteLight),
        const SizedBox(width: 16),
        const Icon(
          Icons.thumb_down_outlined,
          size: 16,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 4),
        Text('${post.reactions.dislikes}', style: AppTextStyles.footnoteLight),
        const SizedBox(width: 16),
        const Icon(
          Icons.remove_red_eye_outlined,
          size: 16,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 4),
        Text('${post.views}', style: AppTextStyles.footnoteLight),
      ],
    );
  }

  Widget _buildTags() {
    if (post.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: post.tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#$tag',
                style: AppTextStyles.footnoteLight.copyWith(
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

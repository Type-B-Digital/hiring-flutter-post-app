import 'package:flutter/material.dart';
import 'package:postsapp/core/constants/app_text_styles.dart';
import 'package:postsapp/features/posts/domain/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel postModel;
  const PostCard({super.key, required this.postModel});

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenwidth,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            postModel.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.calloutSemibold,
          ),
          const SizedBox(height: 12),
          Text(
            postModel.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.footnoteRegular,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoItem(
                icon: Icons.favorite,
                iconColor: Colors.red,
                text: postModel.reactions.likes.toString(),
              ),
              const SizedBox(width: 18),
              _InfoItem(
                icon: Icons.visibility,
                text: postModel.views.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  const _InfoItem({required this.icon, required this.text, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor ?? const Color(0xFF999999)),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.captionLight),
      ],
    );
  }
}

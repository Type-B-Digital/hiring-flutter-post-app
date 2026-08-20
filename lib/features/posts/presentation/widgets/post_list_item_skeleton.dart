import 'package:flutter/material.dart';
import '../../../../core/widgets/app_skeleton.dart';

class PostListItemSkeleton extends StatelessWidget {
  const PostListItemSkeleton({super.key});

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
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppSkeleton(width: 32, height: 32, shape: BoxShape.circle),
                SizedBox(width: 8),
                AppSkeleton(width: 100, height: 14),
              ],
            ),
            SizedBox(height: 16),
            AppSkeleton(width: double.infinity, height: 20),
            SizedBox(height: 8),
            AppSkeleton(width: double.infinity, height: 14),
            SizedBox(height: 4),
            AppSkeleton(width: 200, height: 14),
            Spacer(),
            Row(
              children: [
                AppSkeleton(width: 16, height: 16, shape: BoxShape.circle),
                SizedBox(width: 4),
                AppSkeleton(width: 30, height: 12),
                SizedBox(width: 16),
                AppSkeleton(width: 16, height: 16, shape: BoxShape.circle),
                SizedBox(width: 4),
                AppSkeleton(width: 30, height: 12),
                SizedBox(width: 16),
                AppSkeleton(width: 16, height: 16, shape: BoxShape.circle),
                SizedBox(width: 4),
                AppSkeleton(width: 40, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

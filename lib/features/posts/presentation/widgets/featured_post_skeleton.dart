import 'package:flutter/material.dart';
import '../../../../core/widgets/app_skeleton.dart';

class FeaturedPostSkeleton extends StatelessWidget {
  const FeaturedPostSkeleton({super.key});

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
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              clipBehavior: Clip.antiAlias,
              child: const AppSkeleton(borderRadius: BorderRadius.zero),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppSkeleton(height: 20, width: double.infinity),
                  AppSkeleton(height: 20, width: 150),
                  Row(
                    children: [
                      AppSkeleton(width: 16, height: 16, shape: BoxShape.circle),
                      SizedBox(width: 8),
                      AppSkeleton(width: 60, height: 12),
                      Spacer(),
                      AppSkeleton(width: 16, height: 16, shape: BoxShape.circle),
                      SizedBox(width: 8),
                      AppSkeleton(width: 40, height: 12),
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

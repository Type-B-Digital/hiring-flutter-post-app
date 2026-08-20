import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary3,
      unselectedItemColor: AppColors.secondary,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w300, fontSize: 12, height: 16 / 12),
      unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w300, fontSize: 12, height: 16 / 12),
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svgs/home.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn)),
          activeIcon: SvgPicture.asset('assets/svgs/home.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.primary3, BlendMode.srcIn)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svgs/star 1.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn)),
          activeIcon: SvgPicture.asset('assets/svgs/star 1.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.primary3, BlendMode.srcIn)),
          label: 'Top Rate',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svgs/news 1.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn)),
          activeIcon: SvgPicture.asset('assets/svgs/news 1.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.primary3, BlendMode.srcIn)),
          label: 'News',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svgs/messenger 1.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn)),
          activeIcon: SvgPicture.asset('assets/svgs/messenger 1.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.primary3, BlendMode.srcIn)),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/svgs/customers_major.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn)),
          activeIcon: SvgPicture.asset('assets/svgs/customers_major.svg',
              colorFilter:
                  const ColorFilter.mode(AppColors.primary3, BlendMode.srcIn)),
          label: 'Profile',
        ),
      ],
    );
  }
}

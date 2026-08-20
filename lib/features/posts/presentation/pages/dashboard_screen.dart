import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_display_utils.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/post_list_item.dart';
import '../widgets/featured_post_card.dart';
import '../widgets/featured_post_skeleton.dart';
import '../widgets/post_list_item_skeleton.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PostsBloc>().add(PostsFetched());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostsBloc>().add(PostsFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeFeed(),
          const Center(child: Text('Top Rate Screen')),
          const Center(child: Text('News Screen')),
          const Center(child: Text('Chat Screen')),
          const ProfileScreen(),
        ],
      ),
    );
  }

  Widget _buildHomeFeed() {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary1,
        onRefresh: () async {
          context.read<PostsBloc>().add(PostsRefreshed());
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Good Morning!',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = 4;
                        });
                      },
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          String initials = 'G';
                          String? networkImage;

                          if (state is AuthAuthenticated) {
                            final user = state.user;
                            initials = UserDisplayUtils.initialsFor(user);
                            networkImage = user.image;
                          }

                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary1,
                                width: 2.0,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor:
                                  (networkImage == null || networkImage.isEmpty)
                                      ? AppColors.primary3
                                      : Colors.transparent,
                              radius: 18,
                              backgroundImage: (networkImage != null &&
                                      networkImage.isNotEmpty)
                                  ? NetworkImage(networkImage)
                                  : null,
                              child:
                                  (networkImage == null || networkImage.isEmpty)
                                      ? Text(initials,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: AppColors.white))
                                      : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: AppSearchBar(
                  controller: _searchController,
                  hintText: 'Search posts ...',
                  onChanged: (value) {
                    context
                        .read<PostsBloc>()
                        .add(PostsSearchQueryChanged(value));
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Posts',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text('View All',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.success2)),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: BlocBuilder<PostsBloc, PostsState>(
                  builder: (context, state) {
                    if (state.status == PostsStatus.initial) {
                      return ListView.builder(
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.only(
                            left: 24.0, right: 24.0, bottom: 30, top: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return const FeaturedPostSkeleton();
                        },
                      );
                    }
                    if (state.posts.isEmpty) {
                      return const Center(
                          child: Text('No featured posts.',
                              style: TextStyle(color: AppColors.secondary)));
                    }
                    final featuredPosts = state.posts.take(5).toList();
                    return ListView.builder(
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.only(
                          left: 24.0, right: 24.0, bottom: 30, top: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredPosts.length,
                      itemBuilder: (context, index) {
                        return FeaturedPostCard(post: featuredPosts[index]);
                      },
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Posts',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text('View All',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.success2)),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            BlocBuilder<PostsBloc, PostsState>(
              builder: (context, state) {
                if (state.status == PostsStatus.initial) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return const PostListItemSkeleton();
                        },
                        childCount: 5,
                      ),
                    ),
                  );
                }
                if (state.status == PostsStatus.failure &&
                    state.posts.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: AppColors.critical),
                          const SizedBox(height: 16),
                          Text(state.errorMessage),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<PostsBloc>().add(PostsFetched()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (state.posts.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                        child: Text('No posts found.',
                            style: TextStyle(color: AppColors.secondary))),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (index >= state.posts.length) {
                          if (state.status == PostsStatus.failure) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  const Text('Failed to load more posts', style: TextStyle(color: AppColors.critical)),
                                  TextButton(
                                    onPressed: () => context.read<PostsBloc>().add(PostsFetched()),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: PostListItemSkeleton(),
                          );
                        }
                        return PostListItem(post: state.posts[index]);
                      },
                      childCount: state.hasReachedMax
                          ? state.posts.length
                          : state.posts.length + 1,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

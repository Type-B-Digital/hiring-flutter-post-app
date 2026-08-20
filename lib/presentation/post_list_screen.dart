import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:post_app/provider/auth_provider.dart';
import 'package:post_app/provider/post_provider.dart';
import 'package:post_app/widgets/error_view.dart';
import 'package:post_app/widgets/loader.dart';
import 'package:post_app/widgets/post_card.dart';
import 'package:post_app/widgets/search_bar.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().onInit();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 300) {
        context.read<PostProvider>().fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 900 ? 3 : (width >= 600 ? 2 : 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
    
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: Builder(
                builder: (context) {
                  final user = context.watch<AuthProvider>().user;
                  final initials = user == null
                      ? '?'
                      : '${user.firstName[0]}${user.lastName[0]}'.toUpperCase();
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const PostSearchField(),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<PostProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const LoadingView();
                    }

                    if (provider.error != null) {
                      return ErrorView(
                        message: provider.error!,
                        onRetry: () => context.read<PostProvider>().onInit(),
                      );
                    }

                    if (provider.posts.isEmpty) {
                      return const Center(child: Text('No posts found'));
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<PostProvider>().onInit(),
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverMasonryGrid.count(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childCount: provider.posts.length,
                            itemBuilder: (context, index) {
                              final post = provider.posts[index];
                              return PostCard(
                                post: post,
                                onTap: () => context.push('/posts/${post.id}'),
                              );
                            },
                          ),
                          if (provider.hasMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

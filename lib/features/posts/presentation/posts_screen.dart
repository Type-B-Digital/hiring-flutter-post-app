import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:postsapp/core/constants/app_text_styles.dart';
import 'package:postsapp/core/utils/greeting_helper.dart';
import 'package:postsapp/features/posts/presentation/bloc/post_bloc.dart';
import 'package:postsapp/features/posts/presentation/post_details_screen.dart';
import 'package:postsapp/shared/widgets/custom_text_field.dart';
import 'package:postsapp/shared/widgets/post_card.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(PostsFetchRequestedEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostBloc>().add(PostsNextPageRequestedEvent());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                GreetingHelper.getGreeting(),
                style: AppTextStyles.titleBold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CustomTextField(
                controller: _searchController,
                onChanged: (value) => context.read<PostBloc>().add(
                  PostsSearchChangedEvent(value),
                ),
                hint: 'Search posts...',
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<PostBloc>().add(PostsRefreshRequestedEvent());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: BlocBuilder<PostBloc, PostState>(
                  builder: (context, state) => _buildBody(state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PostState state) {
    if (state is PostsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PostsError) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(child: Text('Something went wrong: ${state.failure.message}')),
        ],
      );
    }
    if (state is PostsEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('No posts found')),
        ],
      );
    }
    if (state is PostsLoadedState) {
      return ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= state.posts.length) {
            return Center(child: CircularProgressIndicator());
          }
          final post = state.posts[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(postId: post.id),
                ),
              );
            },
            child: PostCard(postModel: post),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}

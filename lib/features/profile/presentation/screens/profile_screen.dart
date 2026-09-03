import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/constants/route_constants.dart';
import 'package:movies_app/core/di/app_dependencies.dart';
import 'package:movies_app/core/theme/app_colors.dart';
import 'package:movies_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movies_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:movies_app/features/library/presentation/cubit/history_cubit.dart';
import 'package:movies_app/features/library/presentation/cubit/history_state.dart';
import 'package:movies_app/features/library/presentation/cubit/watchlist_cubit.dart';
import 'package:movies_app/features/library/presentation/cubit/watchlist_state.dart';
import 'package:movies_app/features/home/presentation/widgets/home_movie_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<WatchlistCubit>(
          create: (context) =>
              dependencies.createWatchlistCubit()..startObserving(),
        ),
        BlocProvider<HistoryCubit>(
          create: (context) =>
              dependencies.createHistoryCubit()..startObserving(),
        ),
      ],
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onBackground,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  icon: Icon(Icons.bookmark_outline),
                  text: 'Watch List',
                ),
                Tab(
                  icon: Icon(Icons.folder_open_outlined),
                  text: 'History',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _WatchlistTab(),
                  _HistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final name = user?.name ?? 'John Safwat';
        final avatar = user?.avatarId ?? 'assets/images/auth/avatar_01.png';

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.inputFill,
                backgroundImage: AssetImage(avatar),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProfileStat(
                    label: 'Wish List',
                    count: context.watch<WatchlistCubit>().state.movies.length,
                  ),
                  _ProfileStat(
                    label: 'History',
                    count: context.watch<HistoryCubit>().state.movies.length,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push(RouteConstants.updateProfile),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.read<AuthCubit>().signOut(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Exit',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.logout_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: AppColors.onBackground,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onBackgroundSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _WatchlistTab extends StatelessWidget {
  const _WatchlistTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, state) {
        if (state.status == WatchlistStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.movies.isEmpty) {
          return const _EmptyState(message: 'Your watchlist is empty');
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: state.movies.length,
          itemBuilder: (context, index) {
            final movie = state.movies[index];
            return HomeMovieCard(
              movie: movie.toMovieEntity(),
              width: 100,
              height: 150,
              borderRadius: 12,
              onTap: () => context.push(
                RouteConstants.movieDetailsPath(movie.movieId),
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        if (state.status == HistoryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.movies.isEmpty) {
          return const _EmptyState(message: 'No history found');
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: state.movies.length,
          itemBuilder: (context, index) {
            final movie = state.movies[index];
            return HomeMovieCard(
              movie: movie.toMovieEntity(),
              width: 100,
              height: 150,
              borderRadius: 12,
              onTap: () => context.push(
                RouteConstants.movieDetailsPath(movie.movieId),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/popcorn.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.movie_filter_outlined,
              size: 60,
              color: AppColors.inputFill,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.onBackgroundSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies_app/core/di/app_dependencies.dart';
import 'package:movies_app/core/theme/app_colors.dart';
import 'package:movies_app/features/library/domain/entities/library_movie.dart';
import 'package:movies_app/features/library/presentation/cubit/history_cubit.dart';
import 'package:movies_app/features/library/presentation/cubit/watchlist_cubit.dart';
import 'package:movies_app/features/library/presentation/cubit/watchlist_state.dart';
import 'package:movies_app/features/movies/presentation/cubit/movie_details_cubit.dart';
import 'package:movies_app/features/movies/presentation/cubit/movie_details_state.dart';
import 'package:movies_app/features/home/presentation/widgets/movie_poster_image.dart';
import 'package:movies_app/features/home/presentation/widgets/home_movie_card.dart';

class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({
    super.key,
    this.movieId,
  });

  final int? movieId;

  @override
  Widget build(BuildContext context) {
    if (movieId == null || movieId! <= 0) {
      return const Scaffold(body: Center(child: Text('Invalid Movie ID')));
    }

    final dependencies = context.read<AppDependencies>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<MovieDetailsCubit>(
          create: (context) =>
              dependencies.createMovieDetailsCubit()..load(movieId!),
        ),
        BlocProvider<WatchlistCubit>(
          create: (context) =>
              dependencies.createWatchlistCubit()..startObserving(),
        ),
        BlocProvider<HistoryCubit>(
          create: (context) => dependencies.createHistoryCubit(),
        ),
      ],
      child: const _MovieDetailsView(),
    );
  }
}

class _MovieDetailsView extends StatelessWidget {
  const _MovieDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<MovieDetailsCubit, MovieDetailsState>(
        listener: (context, state) {
          if (state.status == MovieDetailsStatus.success && state.movie != null) {
            context.read<HistoryCubit>().recordMovieView(
                  LibraryMovie.fromMovie(state.movie!),
                );
          }
        },
        builder: (context, state) {
          if (state.status == MovieDetailsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == MovieDetailsStatus.failure) {
            return Center(
              child: Text(state.errorMessage ?? 'Failed to load details'),
            );
          }

          final movie = state.movie;
          if (movie == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 500,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  BlocBuilder<WatchlistCubit, WatchlistState>(
                    builder: (context, watchlistState) {
                      final isInWatchlist =
                          watchlistState.containsMovie(movie.id);
                      return IconButton(
                        icon: Icon(
                          isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                          color: isInWatchlist ? AppColors.primary : Colors.white,
                        ),
                        onPressed: () => context
                            .read<WatchlistCubit>()
                            .toggleMovie(LibraryMovie.fromMovie(movie)),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      MoviePosterImage(
                        imageUrl: movie.bestCoverImage,
                        borderRadius: 0,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.background,
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow,
                              size: 50, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      movie.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${movie.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.onBackgroundSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Watch'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MovieStat(
                          icon: Icons.favorite,
                          value: '${movie.likeCount ?? 0}',
                          color: Colors.yellow,
                        ),
                        _MovieStat(
                          icon: Icons.access_time,
                          value: '${movie.runtime} m',
                          color: Colors.yellow,
                        ),
                        _MovieStat(
                          icon: Icons.star,
                          value: '${movie.rating}',
                          color: Colors.yellow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Summary',
                      style: TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.descriptionFull.isNotEmpty
                          ? movie.descriptionFull
                          : movie.summary,
                      style: const TextStyle(
                        color: AppColors.onBackgroundSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (movie.screenshotUrls.isNotEmpty) ...[
                      const Text(
                        'Screenshots',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: movie.screenshotUrls.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                movie.screenshotUrls[index],
                                width: 250,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (state.suggestions.isNotEmpty) ...[
                      const Text(
                        'More Like This',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.suggestions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final suggestion = state.suggestions[index];
                            return HomeMovieCard(
                              movie: suggestion,
                              width: 146,
                              height: 220,
                              borderRadius: 16,
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailsScreen(
                                    movieId: suggestion.id,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MovieStat extends StatelessWidget {
  const _MovieStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

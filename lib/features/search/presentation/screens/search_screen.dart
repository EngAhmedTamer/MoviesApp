import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/constants/route_constants.dart';
import 'package:movies_app/core/di/app_dependencies.dart';
import 'package:movies_app/core/theme/app_colors.dart';
import 'package:movies_app/features/movies/domain/entities/movies_query.dart';
import 'package:movies_app/features/movies/presentation/cubit/movies_cubit.dart';
import 'package:movies_app/features/movies/presentation/cubit/movies_state.dart';
import 'package:movies_app/features/home/presentation/widgets/home_movie_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();
    return BlocProvider<MoviesCubit>(
      create: (context) => dependencies.createMoviesCubit(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        context.read<MoviesCubit>().loadInitial(query: const MoviesQuery());
      } else {
        context.read<MoviesCubit>().applyQuery(
              MoviesQuery(queryTerm: query.trim()),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: AppColors.onBackground),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: AppColors.onBackgroundSecondary),
                    prefixIcon: Icon(Icons.search, color: AppColors.onBackground),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<MoviesCubit, MoviesState>(
                builder: (context, state) {
                  if (_searchController.text.isEmpty && state.movies.isEmpty) {
                    return const _SearchEmptyState();
                  }

                  if (state.status == MoviesStatus.loading &&
                      state.movies.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state.movies.isEmpty && state.status == MoviesStatus.success) {
                    return const Center(
                      child: Text(
                        'No movies found.',
                        style: TextStyle(color: AppColors.onBackgroundSecondary),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.movies.length,
                    itemBuilder: (context, index) {
                      final movie = state.movies[index];
                      return HomeMovieCard(
                        movie: movie,
                        width: 146,
                        height: 220,
                        borderRadius: 16,
                        onTap: () => context.push(
                          RouteConstants.movieDetailsPath(movie.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/popcorn.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.movie_filter_rounded,
              size: 100,
              color: AppColors.inputFill,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Search for your favorite movie',
            style: TextStyle(
              color: AppColors.onBackgroundSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/constants/route_constants.dart';
import 'package:movies_app/core/di/app_dependencies.dart';
import 'package:movies_app/core/theme/app_colors.dart';
import 'package:movies_app/features/browse/presentation/cubit/browse_cubit.dart';
import 'package:movies_app/features/home/presentation/widgets/home_movie_card.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();
    return BlocProvider<BrowseCubit>(
      create: (context) => dependencies.createBrowseCubit()..load(),
      child: const _BrowseView(),
    );
  }
}

class _BrowseView extends StatelessWidget {
  const _BrowseView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<BrowseCubit, BrowseState>(
          builder: (context, state) {
            if (state is BrowseLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BrowseError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: const TextStyle(color: AppColors.error)),
                    TextButton(
                      onPressed: () => context.read<BrowseCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is BrowseLoaded) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: state.genres.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final genre = state.genres[index];
                        final isSelected = genre == state.selectedGenre;
                        return ChoiceChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (_) =>
                              context.read<BrowseCubit>().selectGenre(genre),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.inputFill,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.onBackground,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.isLoadingGenre
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: state.moviesByGenre.length,
                            itemBuilder: (context, index) {
                              final movie = state.moviesByGenre[index];
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
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

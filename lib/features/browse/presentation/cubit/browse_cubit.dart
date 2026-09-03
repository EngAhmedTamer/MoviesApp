import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:movies_app/features/movies/domain/entities/movie.dart';
import 'package:movies_app/features/movies/domain/entities/movies_query.dart';
import 'package:movies_app/features/movies/domain/use_cases/get_movies.dart';

abstract class BrowseState extends Equatable {
  const BrowseState();
  @override
  List<Object?> get props => [];
}

class BrowseInitial extends BrowseState {}

class BrowseLoading extends BrowseState {}

class BrowseLoaded extends BrowseState {
  const BrowseLoaded({
    required this.genres,
    required this.moviesByGenre,
    required this.selectedGenre,
    this.isLoadingGenre = false,
  });

  final List<String> genres;
  final List<Movie> moviesByGenre;
  final String selectedGenre;
  final bool isLoadingGenre;

  BrowseLoaded copyWith({
    List<String>? genres,
    List<Movie>? moviesByGenre,
    String? selectedGenre,
    bool? isLoadingGenre,
  }) {
    return BrowseLoaded(
      genres: genres ?? this.genres,
      moviesByGenre: moviesByGenre ?? this.moviesByGenre,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      isLoadingGenre: isLoadingGenre ?? this.isLoadingGenre,
    );
  }

  @override
  List<Object?> get props => [genres, moviesByGenre, selectedGenre, isLoadingGenre];
}

class BrowseError extends BrowseState {
  const BrowseError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class BrowseCubit extends Cubit<BrowseState> {
  BrowseCubit(this._getMovies) : super(BrowseInitial());

  final GetMovies _getMovies;

  Future<void> load() async {
    emit(BrowseLoading());
    try {
      // Fetch initial list to extract genres
      final page = await _getMovies(const MoviesQuery(limit: 50));
      final allGenres = <String>{};
      for (final movie in page.movies) {
        if (movie.genres != null) {
          allGenres.addAll(movie.genres!);
        }
      }

      final sortedGenres = allGenres.toList()..sort();
      if (sortedGenres.isEmpty) {
        emit(const BrowseError('No categories found.'));
        return;
      }

      final firstGenre = sortedGenres.first;
      final genreMoviesPage = await _getMovies(MoviesQuery(genre: firstGenre));

      emit(BrowseLoaded(
        genres: sortedGenres,
        moviesByGenre: genreMoviesPage.movies,
        selectedGenre: firstGenre,
      ));
    } catch (e) {
      emit(BrowseError(e.toString()));
    }
  }

  Future<void> selectGenre(String genre) async {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;
    if (currentState.selectedGenre == genre) return;

    emit(currentState.copyWith(selectedGenre: genre, isLoadingGenre: true));

    try {
      final page = await _getMovies(MoviesQuery(genre: genre));
      emit(currentState.copyWith(
        selectedGenre: genre,
        moviesByGenre: page.movies,
        isLoadingGenre: false,
      ));
    } catch (e) {
      emit(BrowseError(e.toString()));
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:movies_app/core/network/dio_client.dart';
import 'package:movies_app/core/storage/app_preferences.dart';
import 'package:movies_app/features/auth/data/data_sources/auth_firebase_data_source.dart';
import 'package:movies_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movies_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movies_app/features/auth/domain/use_cases/delete_account.dart';
import 'package:movies_app/features/auth/domain/use_cases/get_current_user.dart';
import 'package:movies_app/features/auth/domain/use_cases/observe_auth_state.dart';
import 'package:movies_app/features/auth/domain/use_cases/register_with_email.dart';
import 'package:movies_app/features/auth/domain/use_cases/send_password_reset_email.dart';
import 'package:movies_app/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:movies_app/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:movies_app/features/auth/domain/use_cases/sign_out.dart';
import 'package:movies_app/features/auth/domain/use_cases/update_profile.dart';
import 'package:movies_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movies_app/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:movies_app/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:movies_app/features/browse/presentation/cubit/browse_cubit.dart';
import 'package:movies_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:movies_app/features/library/data/data_sources/library_firestore_data_source.dart';
import 'package:movies_app/features/library/data/repositories/library_repository_impl.dart';
import 'package:movies_app/features/library/domain/repositories/library_repository.dart';
import 'package:movies_app/features/library/domain/use_cases/add_to_watchlist.dart';
import 'package:movies_app/features/library/domain/use_cases/observe_history.dart';
import 'package:movies_app/features/library/domain/use_cases/observe_is_in_watchlist.dart';
import 'package:movies_app/features/library/domain/use_cases/observe_watchlist.dart';
import 'package:movies_app/features/library/domain/use_cases/record_history.dart';
import 'package:movies_app/features/library/domain/use_cases/remove_from_watchlist.dart';
import 'package:movies_app/features/library/presentation/cubit/history_cubit.dart';
import 'package:movies_app/features/library/presentation/cubit/watchlist_cubit.dart';
import 'package:movies_app/features/movies/data/data_sources/movies_remote_data_source_impl.dart';
import 'package:movies_app/features/movies/data/repositories/movies_repository_impl.dart';
import 'package:movies_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movies_app/features/movies/domain/use_cases/get_movie_details.dart';
import 'package:movies_app/features/movies/domain/use_cases/get_movie_suggestions.dart';
import 'package:movies_app/features/movies/domain/use_cases/get_movies.dart';
import 'package:movies_app/features/movies/presentation/cubit/movie_details_cubit.dart';
import 'package:movies_app/features/movies/presentation/cubit/movies_cubit.dart';

class AppDependencies {
  AppDependencies._({
    required this.appPreferences,
    required this.dioClient,
    required this.moviesRepository,
    required this.getMovies,
    required this.getMovieDetails,
    required this.getMovieSuggestions,
    required this.authRepository,
    required this.observeAuthState,
    required this.signInWithEmail,
    required this.registerWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    required this.updateProfile,
    required this.deleteAccount,
    required this.sendPasswordResetEmail,
    required this.libraryRepository,
    required this.observeWatchlist,
    required this.observeIsInWatchlist,
    required this.addToWatchlist,
    required this.removeFromWatchlist,
    required this.observeHistory,
    required this.recordHistory,
  });

  final AppPreferences appPreferences;
  final DioClient dioClient;
  final MoviesRepository moviesRepository;
  final GetMovies getMovies;
  final GetMovieDetails getMovieDetails;
  final GetMovieSuggestions getMovieSuggestions;

  final AuthRepository authRepository;
  final ObserveAuthState observeAuthState;
  final SignInWithEmail signInWithEmail;
  final RegisterWithEmail registerWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final UpdateProfile updateProfile;
  final DeleteAccount deleteAccount;
  final SendPasswordResetEmail sendPasswordResetEmail;

  final LibraryRepository libraryRepository;
  final ObserveWatchlist observeWatchlist;
  final ObserveIsInWatchlist observeIsInWatchlist;
  final AddToWatchlist addToWatchlist;
  final RemoveFromWatchlist removeFromWatchlist;
  final ObserveHistory observeHistory;
  final RecordHistory recordHistory;

  static AppDependencies create() {
    final appPreferences = AppPreferences();
    final dioClient = DioClient();

    final moviesDataSource = MoviesRemoteDataSourceImpl(dioClient.client);
    final moviesRepository = MoviesRepositoryImpl(moviesDataSource);

    final bool isFirebaseReady = Firebase.apps.isNotEmpty;

    final FirebaseAuth? firebaseAuth = isFirebaseReady ? FirebaseAuth.instance : null;
    final FirebaseFirestore? firebaseFirestore = isFirebaseReady ? FirebaseFirestore.instance : null;
    final googleSignIn = GoogleSignIn.instance;
    
    final authDataSource = AuthFirebaseDataSource(
      firebaseAuth: firebaseAuth ?? _SafeDummyFirebaseAuth(),
      firebaseFirestore: firebaseFirestore ?? _SafeDummyFirebaseFirestore(),
      googleSignIn: googleSignIn,
    );
    final authRepository = AuthRepositoryImpl(authDataSource);

    final libraryDataSource = LibraryFirestoreDataSource(
      firebaseAuth: firebaseAuth ?? _SafeDummyFirebaseAuth(),
      firebaseFirestore: firebaseFirestore ?? _SafeDummyFirebaseFirestore(),
    );
    final libraryRepository = LibraryRepositoryImpl(libraryDataSource);

    return AppDependencies._(
      appPreferences: appPreferences,
      dioClient: dioClient,
      moviesRepository: moviesRepository,
      getMovies: GetMovies(moviesRepository),
      getMovieDetails: GetMovieDetails(moviesRepository),
      getMovieSuggestions: GetMovieSuggestions(moviesRepository),
      authRepository: authRepository,
      observeAuthState: ObserveAuthState(authRepository),
      signInWithEmail: SignInWithEmail(authRepository),
      registerWithEmail: RegisterWithEmail(authRepository),
      signInWithGoogle: SignInWithGoogle(authRepository),
      signOut: SignOut(authRepository),
      getCurrentUser: GetCurrentUser(authRepository),
      updateProfile: UpdateProfile(authRepository),
      deleteAccount: DeleteAccount(authRepository),
      sendPasswordResetEmail: SendPasswordResetEmail(authRepository),
      libraryRepository: libraryRepository,
      observeWatchlist: ObserveWatchlist(libraryRepository),
      observeIsInWatchlist: ObserveIsInWatchlist(libraryRepository),
      addToWatchlist: AddToWatchlist(libraryRepository),
      removeFromWatchlist: RemoveFromWatchlist(libraryRepository),
      observeHistory: ObserveHistory(libraryRepository),
      recordHistory: RecordHistory(libraryRepository),
    );
  }

  // Blocs
  AuthCubit createAuthCubit() => AuthCubit(
        observeAuthState: observeAuthState,
        signInWithEmail: signInWithEmail,
        registerWithEmail: registerWithEmail,
        signInWithGoogle: signInWithGoogle,
        signOut: signOut,
      );

  ProfileCubit createProfileCubit() => ProfileCubit(
        getCurrentUser: getCurrentUser,
        updateProfile: updateProfile,
        deleteAccount: deleteAccount,
      );

  PasswordResetCubit createPasswordResetCubit() => PasswordResetCubit(
        sendPasswordResetEmail,
      );

  HomeCubit createHomeCubit() => HomeCubit(getMovies: getMovies);

  BrowseCubit createBrowseCubit() => BrowseCubit(getMovies);

  MoviesCubit createMoviesCubit() => MoviesCubit(getMovies);

  MovieDetailsCubit createMovieDetailsCubit() => MovieDetailsCubit(
        getMovieDetails: getMovieDetails,
        getMovieSuggestions: getMovieSuggestions,
      );

  WatchlistCubit createWatchlistCubit() => WatchlistCubit(
        observeWatchlist: observeWatchlist,
        addToWatchlist: addToWatchlist,
        removeFromWatchlist: removeFromWatchlist,
      );

  HistoryCubit createHistoryCubit() => HistoryCubit(
        observeHistory: observeHistory,
        recordHistory: recordHistory,
      );
}

class _SafeDummyFirebaseAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
  
  @override
  Stream<User?> authStateChanges() => Stream.value(null);
  
  @override
  User? get currentUser => null;
}

class _SafeDummyFirebaseFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => _SafeDummyCollectionReference();
  
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) => 
      _SafeDummyCollectionReference();
}

class _SafeDummyCollectionReference implements CollectionReference<Map<String, dynamic>> {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) => _SafeDummyDocumentReference();

  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) => _SafeDummyQuery();
}

class _SafeDummyDocumentReference implements DocumentReference<Map<String, dynamic>> {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) =>
      const Stream.empty();
  
  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
     return _SafeDummyDocumentSnapshot();
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) => _SafeDummyCollectionReference();

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {}
  
  @override
  Future<void> delete() async {}
}

class _SafeDummyQuery implements Query<Map<String, dynamic>> {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) =>
      const Stream.empty();
}

class _SafeDummyDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  bool get exists => false;

  @override
  Map<String, dynamic>? data() => null;
}

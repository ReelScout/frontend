import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/content/content_bloc.dart';
import 'package:frontend/bloc/forum/posts_bloc.dart';
import 'package:frontend/bloc/forum/threads_bloc.dart';
import 'package:frontend/bloc/navigation/navigation_bloc.dart';
import 'package:frontend/bloc/search/search_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_bloc.dart';
import 'package:frontend/bloc/watchlist/watchlist_bloc.dart';
import 'package:frontend/config/event_bus.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/content_service.dart';
import 'package:frontend/services/forum_service.dart';
import 'package:frontend/services/search_service.dart';
import 'package:frontend/services/token_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/services/watchlist_service.dart';
import 'package:frontend/styles/app_theme.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/bloc/auth/auth_event.dart';
import 'package:frontend/bloc/auth/auth_state.dart';
import 'package:frontend/services/chat_realtime_service.dart';
import 'package:frontend/config/chat_event_bus.dart';
import 'package:frontend/config/unread_badge.dart';

void main() {
  configureDependencies();
  runApp(const ReelScoutApp());
}

class ReelScoutApp extends StatelessWidget {
  const ReelScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final bloc = AuthBloc(
              authService: getIt<AuthService>(),
              tokenService: getIt<TokenService>(),
            );
            // Listen for global logout signals and route through the bloc
            globalEventBus.onLogout.listen((_) {
              bloc.add(LogoutRequested());
            });
            bloc.add(AuthCheckRequested());
            return bloc;
          },
        ),
        BlocProvider<UserProfileBloc>(
          create: (context) => UserProfileBloc(
            userService: getIt<UserService>(),
            tokenService: getIt<TokenService>(),
          ),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(),
        ),
        BlocProvider<ContentBloc>(
          create: (context) => ContentBloc(
            contentService: getIt<ContentService>(),
          ),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
            searchService: getIt<SearchService>(),
          ),
        ),
        BlocProvider<WatchlistBloc>(
          create: (context) => WatchlistBloc(
            watchlistService: getIt<WatchlistService>(),
          ),
        ),
        BlocProvider<ThreadsBloc>(
          create: (context) => ThreadsBloc(
              forumService: getIt<ForumService>()
          ),
        ),
        BlocProvider<PostsBloc>(
          create: (context) => PostsBloc(
              forumService: getIt<ForumService>()
          ),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
        listener: (context, state) async {
          final realtime = getIt<ChatRealtimeService>();
          if (state is AuthSuccess) {
            await chatEventBus.attach(realtime); // connects + subscribes globally
          } else if (state is AuthLoggedOut) {
            chatEventBus.detach();
            realtime.disconnect();
            unreadBadge.clear();
          }
        },
        child: MaterialApp(
          title: 'ReelScout',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}

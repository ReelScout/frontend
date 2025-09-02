import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/bottom_navbar.dart';
import '../pages/home_page.dart';
import 'search_screen.dart';
import '../pages/profile_page.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../bloc/navigation/navigation_event.dart';
import '../bloc/navigation/navigation_state.dart';
import '../styles/app_colors.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = useMemoized(() => [
      const HomePage(),
      const SearchScreen(),
      const ProfilePage(),
    ]);

    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: IndexedStack(
              index: state.selectedIndex,
              children: screens,
            ),
            bottomNavigationBar: BottomNavbar(
              selectedIndex: state.selectedIndex,
              onItemTapped: (index) {
                context.read<NavigationBloc>().add(TabSelected(index: index));
              },
            ),
          );
        },
      ),
    );
  }
}
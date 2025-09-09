import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/bloc/navigation/navigation_bloc.dart';
import 'package:frontend/bloc/navigation/navigation_event.dart';
import 'package:frontend/bloc/navigation/navigation_state.dart';
import 'package:frontend/components/bottom_navbar.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/pages/chats_list_page.dart';
import 'package:frontend/styles/app_colors.dart';
import 'package:frontend/screens/search_screen.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = useMemoized(() => const [
      HomePage(),
      SearchScreen(),
      ChatsListPage(),
      ProfilePage(),
    ]);

    return BlocBuilder<NavigationBloc, NavigationState>(
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
    );
  }
}

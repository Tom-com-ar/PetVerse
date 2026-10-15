import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_breakpoints.dart';
import 'adoption_screen.dart';
import 'chat_screen.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';
import '../services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final User user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        context.read<ProfileService>().ensurePublicProfile(widget.user),
      );
    });
  }

  List<Widget> _pages() => [
    FeedScreen(user: widget.user),
    AdoptionScreen(user: widget.user),
    ChatScreen(user: widget.user),
    ProfileScreen(user: widget.user),
  ];

  static const _navigationItems = [
    _NavigationItem(
      Icons.dynamic_feed_outlined,
      Icons.dynamic_feed,
      'Publicaciones',
      'Inicio',
    ),
    _NavigationItem(
      Icons.volunteer_activism_outlined,
      Icons.volunteer_activism,
      'Adopción',
      'Adopción',
    ),
    _NavigationItem(Icons.forum_outlined, Icons.forum, 'Mensajes', 'Chats'),
    _NavigationItem(Icons.person_outline, Icons.person, 'Mi perfil', 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wideNavigation = width >= AppBreakpoints.tablet;
    final compactLabels = width < AppBreakpoints.mobile;
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets_rounded),
            SizedBox(width: 8),
            Text('PetVerse'),
          ],
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width < 430)
            IconButton(
              onPressed: () => context.read<AuthProvider>().signOut(),
              tooltip: 'Salir',
              icon: const Icon(Icons.logout),
            )
          else
            TextButton.icon(
              onPressed: () => context.read<AuthProvider>().signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Salir'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: wideNavigation
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: -0.6,
                  destinations: [
                    for (final item in _navigationItems)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages(),
                  ),
                ),
              ],
            )
          : IndexedStack(index: _selectedIndex, children: _pages()),
      bottomNavigationBar: wideNavigation
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: [
                for (final item in _navigationItems)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: compactLabels ? item.compactLabel : item.label,
                  ),
              ],
            ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(
    this.icon,
    this.selectedIcon,
    this.label,
    this.compactLabel,
  );

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String compactLabel;
}

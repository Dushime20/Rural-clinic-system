import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../generated/app_localizations.dart';

class MainNavigationWrapper extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainNavigationWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/diagnosis');
        break;
      case 2:
        context.go('/patients');
        break;
      case 3:
        context.go('/pharmacies');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: l10n.home),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: l10n.diagnosis,
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: l10n.patients),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy),
            label: l10n.pharmacies,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 40),
      //   child: FloatingActionButton(
      //     heroTag: 'main_fab', // Unique hero tag
      //     onPressed: () {
      //       context.go('/diagnosis');
      //     },
      //     child: const Icon(Icons.add),
      //   ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

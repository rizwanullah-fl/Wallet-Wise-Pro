import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: 'home'.tr,
        ),
        NavigationDestination(
          icon: Icon(Icons.credit_card_outlined),
          label: 'accounts'.tr,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_2_outlined),
          label: 'debts'.tr,
        ),
        NavigationDestination(
          icon: Icon(Icons.view_carousel_outlined),
          label: 'overview'.tr,
        ),
      ],
    );
  }
}

class CustomBottomNavigationBar2 extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar2({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 0,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: 'home'.tr,
        ),
        NavigationDestination(
          icon: Icon(Icons.credit_card_outlined),
          label: 'accounts'.tr,
        ),
        NavigationDestination(
          icon: Icon(Icons.person_2_outlined),
          label: 'debts'.tr,
        ),
        NavigationDestination(
          icon: Icon(Icons.view_carousel_outlined),
          label: 'overview'.tr,
        ),
        NavigationDestination(
          icon: Icon(Icons.credit_card_outlined),
          label: 'Accounts',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_2_outlined),
          label: 'Debts',
        ),
        NavigationDestination(
          icon: Icon(Icons.view_carousel_outlined),
          label: 'Overview',
        ),
      ],
    );
  }
}

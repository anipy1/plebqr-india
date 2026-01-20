import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class TabContainerScreen extends StatelessWidget {
  const TabContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabState = CupertinoTabPage.of(context);

    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(label: 'Pay', icon: Icon(Icons.payment)),
          BottomNavigationBarItem(
            label: 'Transactions',
            icon: Icon(Icons.history),
          ),
        ],
      ),
    );
  }
}

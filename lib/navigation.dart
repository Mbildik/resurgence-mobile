import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/chat/chat.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/item/npc_counter_ui.dart';
import 'package:resurgence/player/profile.dart';
import 'package:resurgence/profile/profile_tab.dart';
import 'package:resurgence/tab_navigator.dart';
import 'package:resurgence/task/task_tab.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final List<NavigationItem> navigationItems = [
    NavigationItem(
      S.profile,
      Icon(Icons.person),
      Icon(Icons.person_outline),
      GlobalKey<NavigatorState>(),
      ProfileTab(),
    ),
    NavigationItem(
      S.tasks,
      Icon(Icons.handyman),
      Icon(Icons.handyman_outlined),
      GlobalKey<NavigatorState>(),
      TaskTab(),
    ),
    NavigationItem(
      S.npc,
      Icon(Icons.shopping_basket),
      Icon(Icons.shopping_basket_outlined),
      GlobalKey<NavigatorState>(),
      NPCCounter(),
    ),
    NavigationItem(
      'Haberler',
      Icon(Icons.home),
      Icon(Icons.home_outlined),
      GlobalKey<NavigatorState>(),
      PlayerProfile('eee'),
    ),
    NavigationItem(
      S.chat,
      _chatIcon(Icon(Icons.chat)),
      _chatIcon(Icon(Icons.chat_outlined)),
      GlobalKey<NavigatorState>(),
      ChatPage(),
    ),
  ];

  int _bottomNavigationBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = navigationItems.asMap().entries.map((e) {
      var index = e.key;
      var item = e.value;
      return BottomNavigationBarItem(
          icon: index == _bottomNavigationBarIndex
              ? item.selectedIcon
              : item.unselectedIcon,
          label: item.name);
    }).toList(growable: false);

    final screens = navigationItems.asMap().entries.map((e) {
      var index = e.key;
      var item = e.value;
      return _buildOffstageNavigator(index, item);
    }).toList(growable: false);

    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await navigationItems[_bottomNavigationBarIndex]
                .key
                .currentState
                .maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_bottomNavigationBarIndex != 0) {
            _onNavigationButtonTap(0);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(children: screens),
        bottomNavigationBar: BottomNavigationBar(
          items: items,
          currentIndex: _bottomNavigationBarIndex,
          onTap: _onNavigationButtonTap,
        ),
      ),
    );
  }

  void _onNavigationButtonTap(int index) {
    // todo döküman yaz
    if (index == this._bottomNavigationBarIndex) {
      navigationItems[index]
          .key
          .currentState
          .popUntil((route) => route.isFirst);
    } else {
      setState(() => this._bottomNavigationBarIndex = index);
    }
  }

  Widget _buildOffstageNavigator(int index, NavigationItem item) {
    return Offstage(
      offstage: _bottomNavigationBarIndex != index,
      child: TabNavigator(item),
    );
  }

  static Widget _chatIcon(Icon icon) {
    // todo chat kısmına bir bug var.
    //  chat mesajları sadece geri tuşuna basınca okundu olarak
    //  server'a gönderiliyor
    return Selector<ChatState, int>(
      selector: (_, s) => s.unreadMessageCount(),
      shouldRebuild: (a, b) => a != b,
      builder: (context, unread, child) {
        if (unread <= 0) return child;

        return Stack(
          children: [
            child,
            Positioned(
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                width: 8.0,
                height: 8.0,
              ),
            ),
          ],
        );
      },
      child: icon,
    );
  }
}

class NavigationItem {
  final String name;
  final Widget selectedIcon;
  final Widget unselectedIcon;
  final GlobalKey<NavigatorState> key;
  final Widget screen;

  const NavigationItem(
    this.name,
    this.selectedIcon,
    this.unselectedIcon,
    this.key,
    this.screen,
  );
}

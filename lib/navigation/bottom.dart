import 'package:flutter/material.dart';
import 'package:hey_chat/screens/chat/chat.dart';
import 'package:hey_chat/screens/profile/profile.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class BotNav extends StatefulWidget {
  const BotNav({ Key? key}) : super(key: key);

  @override
  _BotNavState createState() => _BotNavState();
}

class _BotNavState extends State<BotNav> {

  PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.chat_outlined),
        //selectedIcon: Icon(Icons.chat),
        title: ("Chats"),
        activeColorPrimary: Colors.redAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person_outline),
        //selectedIcon: Icon(Icons.chat),
        title: ("Profile"),
        activeColorPrimary: Colors.redAccent,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  List<Widget> _buildScreens() {
    return [
      const Chat(),
      const Profile()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        child: Scaffold(
          body: PersistentTabView(
            context,
            controller: _controller,
            screens: _buildScreens(),
            items: _navBarsItems(),
            confineInSafeArea: true,
            backgroundColor: Colors.white, // Default is Colors.white.
            handleAndroidBackButtonPress: true, // Default is true.
            resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
            stateManagement: true, // Default is true.
            hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
            decoration: NavBarDecoration(
              borderRadius: BorderRadius.circular(10.0),
              colorBehindNavBar: Colors.white,
            ),
            popAllScreensOnTapOfSelectedTab: true,
            popActionScreens: PopActionScreensType.all,
            itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
            ),
            screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
              animateTabTransition: true,
              curve: Curves.ease,
              duration: Duration(milliseconds: 200),
            ),
            navBarStyle: NavBarStyle.style1, // Choose the nav bar style with this property.
          ),
        ),
      ),
    );
  }
}
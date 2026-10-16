import 'package:nfeapp_flutter/app/modules/profile/modules/orders_finish/orders_finish_page.dart';
import 'package:nfeapp_flutter/app/modules/profile/modules/orders_open/orders_open_page.dart';
import 'package:nfeapp_flutter/app/modules/profile/modules/orders_wait/orders_local_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? userLogin;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _children = [const Dashboard(), const ProfilePage()];

  @override
  void initState() {
    super.initState();
    _loadUserLogin();
  }

  String formatCamelCase(String text) {
    if (text.isEmpty) return text;

    final words = text.split(' ');
    return words
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _loadUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('userLogin');

    setState(() {
      userLogin = login;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset("assets/bg-login.jpg", fit: BoxFit.cover),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              userLogin != null
                  ? 'Bem-vindo , ${formatCamelCase(userLogin!)}'
                  : 'Bem-vindo',
            ),
            backgroundColor: colorScheme.primary,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.toNamed("/finish_cart");
            },
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: onTabTapped,
            fixedColor: colorScheme.primary,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
          body: _children[_currentIndex],
        ),
      ],
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tabs = [
      const Tab(text: 'Pedidos Offline'),
      const Tab(text: 'Pre Pedidos'),
      const Tab(text: 'Pedidos'),
    ];

    final tabViews = [
      const LocalOrdersPage(),
      const OrdersOpenPage(),
      const OrdersFinishPage(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: TabBar(
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 25),
                    indicator: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: colorScheme.onPrimary,
                    unselectedLabelColor: Colors.grey[800],
                    dividerColor: Colors.transparent,
                    tabs: tabs,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: TabBarView(children: tabViews)),
            ],
          ),
        ),
      ),
    );
  }
}

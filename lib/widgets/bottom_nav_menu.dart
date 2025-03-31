import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavMenu extends StatefulWidget {
  final String jsonPath;
  const BottomNavMenu({Key? key, required this.jsonPath}) : super(key: key);

  @override
  _BottomNavMenuState createState() => _BottomNavMenuState();
}

class _BottomNavMenuState extends State<BottomNavMenu> {
  int _currentIndex = 0;
  List<dynamic> menuItems = [];

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  Future<void> loadMenu() async {
    final String response = await rootBundle.loadString(widget.jsonPath);
    final data = json.decode(response);
    setState(() {
      menuItems = data['menu'] ?? [];
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    final screenRoute = menuItems[index]['screen'];
    if (screenRoute != null) {
      Navigator.pushNamed(context, screenRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) return const SizedBox.shrink();
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: onTabTapped,
      items: menuItems.map<BottomNavigationBarItem>((item) {
        return BottomNavigationBarItem(
          icon: Icon(getIconFromName(item['icon'])),
          label: item['title'] ?? '',
        );
      }).toList(),
    );
  }

  IconData getIconFromName(String? name) {
    switch (name) {
      case 'home':
        return Icons.home;
      case 'person':
        return Icons.person;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.help;
    }
  }
}

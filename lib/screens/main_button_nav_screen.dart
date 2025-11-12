import 'package:flutter/material.dart';
import 'package:project/screens/shop_screen.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'explore_screen.dart';
import 'favourite_screen.dart';

class NavigationBarScreen extends StatefulWidget {
  const NavigationBarScreen({super.key});

  @override
  State<NavigationBarScreen> createState() => _NavigationBarScreenState();
}

class _NavigationBarScreenState extends State<NavigationBarScreen> {

  int _selectedIndex = 0;
  final List<Widget> _screens = [
    ShopScreen(),
    ExploreScreen(),
    CartScreen(),
    FavoriteScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (mounted) {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          selectedItemColor: Color(0xFF53B175),
          unselectedItemColor: Colors.black,
          showSelectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop),label: 'Shop'),
            BottomNavigationBarItem(icon: Icon(Icons.explore),label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart),label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border),label: 'Favorite'),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: 'Account'),
          ]
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellLayout extends StatelessWidget {
  final Widget child;
  const ShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    int index = 0;
    if (location.startsWith('/Bookings')) index = 1;
    if (location.startsWith('/Profile')) index = 2;

    // ✅ Decide title based on route
   
    return Scaffold(
    

      body: child,

      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: index,
      //   backgroundColor: Colors.black,
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: Colors.greenAccent,
      //   unselectedItemColor: Colors.white,
      //   onTap: (i) {
      //     if (i == 0) context.go('/home');
      //     if (i == 1) context.go('/Bookings');
      //      if (i == 2) context.go('/Profile');
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: "Bookings"),
      //     BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: "Profile"),
      //   ],
      // ),
    );
  }
}
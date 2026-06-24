import 'dart:async';
import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/navbar/shell.dart';
import 'package:field_star_technician_app/pages/Assign_Jobs/assign_jobs.dart';
import 'package:field_star_technician_app/pages/JobDetails/jobdetails.dart';
import 'package:field_star_technician_app/pages/Profile/profile_screen.dart';
import 'package:field_star_technician_app/pages/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouter appRouter = GoRouter(
   initialLocation: '/login',

  // refreshListenable: GoRouterRefreshStream(
  //   FirebaseAuth.instance.authStateChanges(),
  // ),
  refreshListenable: GoRouterRefreshStream(
  Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session),
),

  redirect: (context, state) {
  final session = Supabase.instance.client.auth.currentSession;
  final isLoggedIn = session != null;

  final isLoginPage = state.matchedLocation == '/login';
  final isLandingPage = state.matchedLocation == '/';

  // If logged in, redirect away from auth pages to home
  if (isLoggedIn && (isLoginPage || isLandingPage)) {
    return '/Home';
  }

  // If not logged in, protect private routes and redirect to login
  if (!isLoggedIn &&
      state.matchedLocation != '/' &&
      state.matchedLocation != '/login') {
    return '/login';
  }

  return null;
},

  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ShellLayout(child: child);
      },
      routes: [
       
        GoRoute(
          path: '/Home',
          builder: (context, state) => AssignJobs(),
        ),

        // GoRoute(
        //   path: '/Bookings',
        //   builder: (_, _) => const Booking(),
        // ),
        GoRoute(
          path: '/Profile',
          builder: (_, _) => const ProfileScreen(),
        ),
      ],
    ),

 GoRoute(
  path: '/jobdetails',
  builder: (context, state) {
    final complaint = state.extra as RaiseComplaintModel;
    return Jobdetails(
      complaint: complaint,
      customerid: complaint.id ,  // ← clean
    );
  },
),
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginScreen(),
    ),

    // GoRoute(
    //   path: '/accountdetails',
    //   builder: (context, state) {
    //     final currentUser = FirebaseAuth.instance.currentUser;
    //     return AccountDetailsScreen(
    //       email: currentUser?.email ?? 'No email available',
    //       uid: currentUser?.uid ?? 'No UID found',
    //     );
    //   },
    // ),
  ],
);
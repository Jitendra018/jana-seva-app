import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/signin.dart';
import 'screens/signup.dart';
import 'screens/role_redirect.dart';
import 'screens/citizen_home.dart';
import 'screens/new_request.dart';
import 'screens/official_dashboard.dart';
import 'screens/request_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GovApp());
}

class GovApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jana Seva App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/roleRedirect': (context) => RoleRedirectPage(),
        '/citizenHome': (context) => CitizenHome(),
        '/newRequest': (context) => NewRequestPage(),
        '/officialDashboard': (context) => OfficialDashboard(),
        '/requestDetail': (context) => RequestDetailPage(),
      },
    );
  }
}

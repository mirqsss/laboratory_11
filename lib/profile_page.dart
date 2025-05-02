import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool('isAuthenticated') ?? false;
    final userEmail = prefs.getString('email') ?? '';

    print('isAuthenticated: $isAuth');
    print('Saved email: $userEmail');

    if (isAuth && userEmail.isNotEmpty) {
      final dbRef = FirebaseDatabase.instance.ref('users');
      final snapshot =
          await dbRef.orderByChild('email').equalTo(userEmail).get();

      print('Snapshot exists: ${snapshot.exists}');
      print('Snapshot value: ${snapshot.value}');

      if (snapshot.exists) {
        final userSnapshot = snapshot.children.first;
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        setState(() {
          name = userData['name'] ?? '';
          email = userData['email'] ?? '';
        });
      } else {
        print('No user found with email $userEmail');
      }
    } else {
      print(
          'User is not authenticated or email not found in SharedPreferences');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('ФИО: $name'),
            Text('Email: $email'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart'; // Экран регистрации

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Проверка данных в Firebase
    final dbRef = FirebaseDatabase.instance.ref('users');
    final snapshot = await dbRef.orderByChild('email').equalTo(email).get();

    if (snapshot.exists) {
      final userData = snapshot.value as Map;
      if (userData.values.any((user) => user['password'] == password)) {
        // Сохраняем данные в SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('isAuthenticated', true);
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        _showError('Неверный пароль');
      }
    } else {
      _showError('Пользователь не найден');
    }
  }

  _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Пароль')),
            ElevatedButton(onPressed: _login, child: Text('Войти')),
            TextButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => RegisterPage())),
              child: Text('Нет аккаунта? Зарегистрируйтесь'),
            ),
          ],
        ),
      ),
    );
  }
}

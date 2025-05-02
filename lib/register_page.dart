import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lab10/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Заполните все поля');
      return;
    }

    final dbRef = FirebaseDatabase.instance.ref('users');
    final userRef = dbRef.push(); // создаем уникальную запись

    await userRef.set({
      'name': name,
      'email': email,
      'password': password,
    });
    await NotificationService.showNotification(
      'Регистрация успешна',
      'Добро пожаловать, $name!',
    );

    // --- Сохраняем в SharedPreferences ---
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('email', email);

    // Переходим на страницу профиля сразу
    Navigator.pushReplacementNamed(context, '/profile');
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
      appBar: AppBar(title: Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'ФИО')),
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Пароль')),
            ElevatedButton(
                onPressed: _register, child: Text('Зарегистрироваться')),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Создать аккаунт',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Имя',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Почта',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              const FilledButton(
                onPressed: null,
                child: Text('Создать аккаунт'),
              ),
              const SizedBox(height: 8),
              Text(
                'Демо L2: отправка формы появится на следующих этапах',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

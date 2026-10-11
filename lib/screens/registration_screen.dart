import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../validation/auth_validators.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Данные проверены. Демо: аккаунт не создаётся.')),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Создать аккаунт',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const ValueKey('registrationName'),
                controller: _nameCtrl,
                validator: AuthValidators.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('registrationEmail'),
                controller: _emailCtrl,
                validator: AuthValidators.email,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Почта',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('registrationPassword'),
                controller: _passwordCtrl,
                validator: AuthValidators.password,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _register(),
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _register,
                child: const Text('Создать аккаунт'),
              ),
              const SizedBox(height: 8),
              Text(
                'Учебный режим: проверка данных без создания аккаунта',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

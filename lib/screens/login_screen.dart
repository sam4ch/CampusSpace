import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../validation/auth_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Вход выполнен в демонстрационном режиме')),
    );
    context.go('/rooms');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.meeting_room, size: 72, color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'CampusSpace',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Удобное бронирование помещений кампуса',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      key: const ValueKey('loginEmail'),
                      controller: _emailCtrl,
                      validator: AuthValidators.email,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Университетская почта',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const ValueKey('loginPassword'),
                      controller: _passwordCtrl,
                      validator: AuthValidators.password,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: _login, child: const Text('Войти')),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Нет аккаунта? Регистрация'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Учебный режим: подойдут любые корректные данные',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

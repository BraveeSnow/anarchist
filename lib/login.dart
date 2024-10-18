import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
          child: Expanded(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  branding(),
                  loginPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget branding() {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: Image.asset("assets/anarchist_transparent.png"),
    );
  }

  Widget loginPrompt() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: AppLocalizations.of(context)!.loginEmail),
          onChanged: (changed) {
            email = changed;
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: AppLocalizations.of(context)!.loginPassword),
          onChanged: (changed) {
            password = changed;
          },
        ),
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: () {},
          child: Text(AppLocalizations.of(context)!.loginButton),
        ),
      ],
    );
  }
}

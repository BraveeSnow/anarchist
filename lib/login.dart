import 'package:anarchist/util/oauth_handler.dart';
import 'package:anarchist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  static const String route = 'login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/splash.png'),
              fit: BoxFit.fill,
              alignment: Alignment.center,
              opacity: 0.15,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: branding(),
                  ),
                  Expanded(
                    child: loginPrompt(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget branding() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FractionallySizedBox(
          widthFactor: 0.5,
          child: Image.asset('assets/anarchist_transparent.png'),
        ),
        const Text("Anarchist", style: TextStyle(fontSize: 36)),
      ],
    );
  }

  Widget loginPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FilledButton.tonal(
            onPressed: () => showSkipPopup(context),
            child: Text(AppLocalizations.of(context)!.loginSkip)),
        FilledButton.tonalIcon(
            onPressed: () async {
              // do not launch browser as webview as per IETF
              // https://www.rfc-editor.org/rfc/rfc8252.txt
              await launchUrl(OAuthHandler.anilistAuthCodeEndpoint,
                  mode: LaunchMode.externalApplication);
            },
            icon: Image.asset('assets/anilist.png', width: 24),
            label: Text(AppLocalizations.of(context)!.loginConnect)),
      ],
    );
  }

  void showSkipPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.loginSkipDialogTitle),
          content: Text(AppLocalizations.of(context)!.loginSkipDialog),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(AppLocalizations.of(context)!.loginSkipBack),
            ),
            TextButton(
              onPressed: () {
                context.push(AnarchistMainPage.route);
              },
              child: Text(AppLocalizations.of(context)!.loginSkipContinue),
            ),
          ],
        );
      },
    );
  }
}

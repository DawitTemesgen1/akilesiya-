import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'dart:developer' as developer;

class SocialMediaUrlLauncher {
  static Future<void> launch(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      developer.log("Error launching URL: $e", name: 'SocialMediaUrl');
    }
  }
}

class SocialMediaUrl extends StatelessWidget {
  const SocialMediaUrl({super.key});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    await SocialMediaUrlLauncher.launch(context, urlString);
  }

  @override
  Widget build(BuildContext context) {
    // A constant for the icon size to easily change all icons at once
    const double customIconSize = 35.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          // THE FIX: Add the iconSize property
          iconSize: customIconSize,
          onPressed: () =>
              _launchURL(context, 'https://youtube.com/your-channel-name'),
          icon: const FaIcon(FontAwesomeIcons.youtube, color: Colors.red),
        ),
        IconButton(
          iconSize: customIconSize,
          onPressed: () =>
              _launchURL(context, 'https://facebook.com/your-page'),
          icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
        ),
        IconButton(
          iconSize: customIconSize,
          onPressed: () =>
              _launchURL(context, 'https://instagram.com/your-profile'),
          icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.purple),
        ),
        IconButton(
          iconSize: customIconSize,
          onPressed: () => _launchURL(context, 'https://t.me/your-channel'),
          icon: const FaIcon(
            FontAwesomeIcons.telegram,
            color: Colors.lightBlue,
          ),
        ),
        IconButton(
          iconSize: customIconSize,
          onPressed: () =>
              _launchURL(context, 'https://tiktok.com/@your-profile'),
          icon: FaIcon(FontAwesomeIcons.tiktok,
              color: Provider.of<ThemeProvider>(context)
                  .getOnSurfaceColor(context)),
        ),
      ],
    );
  }
}

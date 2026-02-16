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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
          context,
          'https://youtube.com/@akilesiya',
          FontAwesomeIcons.youtube,
          Colors.red,
        ),
        _buildSocialIcon(
          context,
          'https://facebook.com/akilesiya',
          FontAwesomeIcons.facebook,
          Colors.blue,
        ),
        _buildSocialIcon(
          context,
          'https://instagram.com/akilesiya',
          FontAwesomeIcons.instagram,
          Colors.purple,
        ),
        _buildSocialIcon(
          context,
          'https://t.me/akilesiya',
          FontAwesomeIcons.telegram,
          Colors.lightBlue,
        ),
        _buildSocialIcon(
          context,
          'https://tiktok.com/@akilesiya',
          FontAwesomeIcons.tiktok,
          Provider.of<ThemeProvider>(context).getOnSurfaceColor(context),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(
      BuildContext context, String url, IconData icon, Color color) {
    return IconButton(
      iconSize: 32.0,
      onPressed: () => _launchURL(context, url),
      icon: FaIcon(icon, color: color),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: const BoxConstraints(),
    );
  }
}

// lib/admin only/admin_hub_screen.dart

import 'package:amde_haymanot_abalat_guday/admin%20only/change.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/manage_custom_structure.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/member_management_cockpit.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/profile_template_builder.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Recommended for Amharic text
import 'package:iconsax/iconsax.dart';

const Color primaryColor = Color.fromARGB(255, 1, 37, 100);

class AdminHubScreen extends StatelessWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'የአስተዳዳሪ ማዕከል',
          style:
              GoogleFonts.notoSansEthiopic(), // Using a font good for Amharic
        ),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAdminCard(
            context,
            icon: Iconsax.user_octagon,
            title: 'የአባላት አስተዳደር ኮክፒት',
            subtitle: 'አጠቃላይ የአባላት መረጃን ያስተዳድሩ፣ ያጽድቁ እና የአገልግሎት ሁኔታን ይቆጣጠሩ።',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const MemberManagementCockpit())),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Iconsax.rulerpen,
            title: 'የመገለጫ አብነት ግንባታ',
            subtitle: 'እንደ "ትውልድ" እና "የአባልነት ደረጃ" ያሉ ብጁ መስኮችን ይፍጠሩ እና ያስተዳድሩ።',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ProfileTemplateBuilderScreen())),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(context,
              icon: Iconsax.setting_3,
              title: 'የመገለጫ እይታን ያብጁ',
              subtitle: 'በተጠቃሚ መገለጫ ገጽ ላይ ያሉትን ክፍሎች አሳይ ወይም ደብቅ።', onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const CustomizeProfileViewScreen()));
          }),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            icon: Iconsax.receipt_search,
            title: 'የተጠቃሚ እንቅስቃሴ መዝገብ',
            subtitle: 'የተጠቃሚ መገለጫ ላይ የተደረጉ ለውጦችን ታሪክ ይመልከቱ።',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ChangeHistoryHubScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        leading: Icon(icon, size: 40, color: primaryColor),
        title: Text(
          title,
          style: GoogleFonts.notoSansEthiopic(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.notoSansEthiopic(),
        ),
        trailing: const Icon(Iconsax.arrow_right_3),
        onTap: onTap,
      ),
    );
  }
}

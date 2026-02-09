import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/sync_provider.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

/// Widget that displays sync status and pending operations count
class SyncStatusIndicator extends StatelessWidget {
  final bool showPendingCount;
  final bool compact;

  const SyncStatusIndicator({
    super.key,
    this.showPendingCount = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final syncProvider = context.watch<SyncProvider>();
    final l10n = AppLocalizations.of(context);
    final isAmharic = Localizations.localeOf(context).languageCode == 'am';

    // Don't show anything if online and no pending operations
    if (syncProvider.isOnline &&
        syncProvider.pendingCount == 0 &&
        !syncProvider.isSyncing) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return _buildCompactIndicator(context, syncProvider, l10n, isAmharic);
    }

    return _buildFullIndicator(context, syncProvider, l10n, isAmharic);
  }

  Widget _buildCompactIndicator(
    BuildContext context,
    SyncProvider syncProvider,
    AppLocalizations? l10n,
    bool isAmharic,
  ) {
    Color backgroundColor;
    IconData icon;
    String? tooltip;

    if (syncProvider.isSyncing) {
      backgroundColor = Colors.blue;
      icon = Iconsax.refresh;
      tooltip = isAmharic ? 'በማስተላለፍ ላይ...' : 'Syncing...';
    } else if (!syncProvider.isOnline) {
      backgroundColor = Colors.orange;
      icon = Iconsax.wifi_square;
      tooltip = isAmharic ? 'ኢንተርኔት የለም' : 'No Internet';
    } else if (syncProvider.pendingCount > 0) {
      backgroundColor = Colors.amber;
      icon = Iconsax.cloud_add;
      tooltip = isAmharic
          ? '${syncProvider.pendingCount} በመጠባበቅ ላይ'
          : '${syncProvider.pendingCount} pending';
    } else {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: syncProvider.isSyncing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon,
                color: (backgroundColor == Colors.amber ||
                        backgroundColor == Colors.orange)
                    ? Colors.black87
                    : Colors.white,
                size: 16),
      ),
    );
  }

  Widget _buildFullIndicator(
    BuildContext context,
    SyncProvider syncProvider,
    AppLocalizations? l10n,
    bool isAmharic,
  ) {
    if (syncProvider.isSyncing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isAmharic ? 'በማስተላለፍ ላይ...' : 'Syncing...',
              style: isAmharic
                  ? GoogleFonts.notoSansEthiopic(
                      color: Colors.black87, fontSize: 12)
                  : GoogleFonts.poppins(color: Colors.black87, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (!syncProvider.isOnline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.wifi_square, color: Colors.black87, size: 16),
            const SizedBox(width: 8),
            Text(
              isAmharic ? 'ኢንተርኔት የለም' : 'No Internet',
              style: isAmharic
                  ? GoogleFonts.notoSansEthiopic(
                      color: Colors.black87, fontSize: 12)
                  : GoogleFonts.poppins(color: Colors.black87, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (syncProvider.pendingCount > 0) {
      return GestureDetector(
        onTap: () => syncProvider.syncNow(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.cloud_add, color: Colors.black87, size: 16),
              const SizedBox(width: 8),
              Text(
                isAmharic
                    ? '${syncProvider.pendingCount} በመጠባበቅ ላይ'
                    : '${syncProvider.pendingCount} pending',
                style: isAmharic
                    ? GoogleFonts.notoSansEthiopic(
                        color: Colors.black87, fontSize: 12)
                    : GoogleFonts.poppins(color: Colors.black87, fontSize: 12),
              ),
              const SizedBox(width: 4),
              const Icon(Iconsax.arrow_right_3,
                  color: Colors.black87, size: 14),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

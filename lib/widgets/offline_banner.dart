import 'package:flutter/material.dart';

/// A banner shown at the top of the character list when the device is offline.
/// Displays how old the cached data is, so the user knows they may be
/// looking at stale information.
class OfflineBanner extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastUpdated;

  const OfflineBanner({
    super.key,
    required this.isOnline,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    // When online, don't show the banner at all.
    if (isOnline) return const SizedBox.shrink();

    final cacheAge = _calculateCacheAge();

    return Container(
      width: double.infinity,
      color: Colors.orange,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: Text(
          'Offline — ${_formatCacheAge(cacheAge)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Returns the duration between now and [lastUpdated], or null if unknown.
  Duration? _calculateCacheAge() {
    if (lastUpdated == null) return null;
    return DateTime.now().difference(lastUpdated!);
  }

  /// Converts a [Duration] into a human-readable string.
  String _formatCacheAge(Duration? age) {
    if (age == null) return 'cached data available';
    if (age.inDays > 0) return 'showing data from ${age.inDays} day(s) ago';
    if (age.inHours > 0) return 'showing data from ${age.inHours} hour(s) ago';
    if (age.inMinutes > 0) {
      return 'showing data from ${age.inMinutes} minute(s) ago';
    }
    return 'showing data from just now';
  }
}

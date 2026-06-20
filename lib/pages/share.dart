import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  Future<void> shareApp() async {
    const String shareText =
        'Download my app now!\n'
        'https://play.google.com/store/apps/details?id=com.example.share_App';

    try {
    
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sharing may not work on web. Please test on Android device.',
            ),
          ),
        );
        return;
      }

      await Share.share(shareText);
    } catch (e) {
      debugPrint('Share Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error while sharing: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton.icon(
          onPressed: shareApp,
          icon: const Icon(Icons.share),
          label: const Text('Share App'),

          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
          ),
        ),
      );
  }
}
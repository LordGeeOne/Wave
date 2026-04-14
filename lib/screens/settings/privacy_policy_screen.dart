import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Last updated: April 11, 2026',
              style: TextStyle(fontSize: 13, color: AppColors.textDim),
            ),
            const SizedBox(height: 24),
            _section(
              'About Wave',
              'Wave is a personal music player application that lets you '
                  'enjoy your locally stored music. We are committed to protecting '
                  'your privacy and ensuring a safe experience while using our app.',
            ),
            _section(
              'Data Collection & Storage',
              'Wave does not collect, transmit, or share any personal data. '
                  'All music data, playlists, and settings are stored locally on '
                  'your device. No information is sent to external servers.',
            ),
            _section(
              'No Analytics or Tracking',
              'We do not use any analytics services, advertising frameworks, '
                  'or tracking tools. Your usage of the app remains entirely private.',
            ),
            _section(
              'No Internet Required',
              'Wave functions entirely offline. No internet connection is '
                  'required to use any feature of the app.',
            ),
            _section(
              'Data Deletion',
              'Since all data is stored locally on your device, you can reset '
                  'all data from the Settings screen at any time. Uninstalling '
                  'the app will also permanently delete all associated data.',
            ),
            _section(
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. Any changes '
                  'will be reflected in the app with an updated revision date.',
            ),
            _section(
              'Contact',
              'If you have any questions or concerns about this Privacy Policy, '
                  'please contact us:',
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developed by NEXARYO',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'admin@nexaryo.co.za',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

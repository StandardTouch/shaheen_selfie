import 'package:flutter/material.dart';
import 'package:shaheen_selfie/screens/withoutbg/home_screen.dart';
import 'package:shaheen_selfie/screens/withbg/withbgcamera_screen.dart';

class BgSelectionScreen extends StatelessWidget {
  const BgSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff002147),
        foregroundColor: Colors.white,
        title: Column(
          children: [
            Image.asset("assets/logo.png", width: 100),
            const SizedBox(height: 4),
            Text(
              "Powered By StandardTouch",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
        toolbarHeight: 100,
        centerTitle: true,
      ),
      body: Center(
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _optionCard(
            context: context,
            icon: Icons.image,
            title: "Keep Background",
            description: "Use this if you want to keep the original background.",
            buttonText: "Use With Background",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WithbgcameraScreen()),
              );
            },
            color: const Color.fromARGB(255, 255, 255, 255),
            iconColor: const Color(0xff002147),
            shadowColor: const Color(0xff002147),
          ),
          const SizedBox(height: 24),
          _optionCard(
            context: context,
            icon: Icons.blur_on,
            title: "Remove Background",
            description: "Select this to automatically remove background.",
            buttonText: "Use Without Background",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            color: const Color.fromARGB(255, 255, 255, 255),
            iconColor: const Color(0xff002147),
            shadowColor: const Color(0xff002147),
          ),
        ],
      ),
    ),
  ),
));

  }

  Widget _optionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    required Color color,
    required Color iconColor,
    required Color shadowColor,
  }) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      shadowColor: shadowColor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(buttonText, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

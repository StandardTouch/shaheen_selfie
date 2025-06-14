import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_selfie/screens/withoutbg/home_screen.dart';
import 'package:shaheen_selfie/screens/withbg/withbgcamera_screen.dart';

class BgSelectionScreen extends StatelessWidget {
  const BgSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
      backgroundColor: const Color(0xff002147),
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/logo.png",
            fit: BoxFit.contain,
            width: 100,
          ),
          Text(
            "Powered By StandardTouch",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
          )
        ],
      ),
      toolbarHeight: 100,
      centerTitle: true,
    ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Would you like to remove the background from your image?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WithbgcameraScreen(),)); // No background removal
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  backgroundColor: const Color(0xff002147),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "I don't want to remove the background",

                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomeScreen(),)); // No background removal
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                    backgroundColor: const Color(0xff002147),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Yes, remove the background",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

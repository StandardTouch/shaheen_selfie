import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';


class BgSelectionScreen extends StatelessWidget {
  const BgSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Option"),
        backgroundColor: const Color(0xff002147), // Change as needed
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add padding for better layout
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // The Question
              const Text(
                'Would you like to remove the background from your image?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),  // Space between question and buttons

              // Option 1: Do not remove background
              ElevatedButton(
                onPressed: () {
                  // Proceed without background removal
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,  // Change button color
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "I don't want to remove the background",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),  // Space between buttons

              // Option 2: Remove background
              ElevatedButton(
  onPressed: () {
    // Proceed to the Home Screen for capturing the image
    context.go('/home');
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red, // Customize button color
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: const Text(
    "I don't want to remove the background", // Text for no background removal
    style: TextStyle(fontSize: 16),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}

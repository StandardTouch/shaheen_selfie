import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shaheen_selfie/services/bg_remove_service.dart';
import 'package:shaheen_selfie/utils/config/logger.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ImagePreview extends ConsumerStatefulWidget {
  const ImagePreview({super.key, required this.imagePath});
  final String imagePath;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends ConsumerState<ImagePreview> {
  void onButtonPress() async {
    try {
      setState(
        () {
          isLoading = true;
        },
      );
      final image = await makeImageTransparent(widget.imagePath);
      // final image = await removeGreenShades(widget.imagePath);

      if (!context.mounted) return;
      context.pushNamed(
        "transparent",
        extra: image,
      );
    } catch (err) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(message: "$err"),
      );
      logger.e("From image preview screen: $err");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.white),
            )
          ],
        ),
        toolbarHeight: 100,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                      colors: [Colors.red, Color(0xff002147), Colors.yellow],
                    ),
                  ),
                  Text(
                    "Working magic on your image... 🪄 ",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Please hold on a moment!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            )
          : Image.file(
              File(widget.imagePath),
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading
          ? const SizedBox.shrink()
          : ElevatedButton(
              onPressed: onButtonPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text("Remove background"),
            ),
    );
  }
}

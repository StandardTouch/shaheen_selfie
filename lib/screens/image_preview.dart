import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
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
          loadingPercent = 0.8;
        },
      );
      final image = await makeImageTransparent(widget.imagePath);

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
        loadingPercent = 1;
        isLoading = false;
      });
    }
  }

  bool isLoading = false;
  double loadingPercent = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff002147),
        foregroundColor: Colors.white,
        title: Image.asset(
          "assets/logo.png",
          fit: BoxFit.contain,
          width: 100,
        ),
        toolbarHeight: 100,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: LinearPercentIndicator(
                addAutomaticKeepAlive: true,
                progressColor: Colors.green[900],
                percent: loadingPercent,
                lineHeight: 20,
                animation: true,
                animateFromLastPercent: true,
                center: Text(
                  "$loadingPercent%",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                animationDuration: 1000,
              ),
            )
          : Image.file(
              File(widget.imagePath),
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
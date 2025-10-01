import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shaheen_selfie/components/dialog.dart';
import 'package:shaheen_selfie/screens/frames.dart';
import 'package:shaheen_selfie/utils/messages.dart';

final formKey = GlobalKey<FormState>();

class TransparentView extends ConsumerStatefulWidget {
  const TransparentView({super.key, required this.imageData});
  final ByteBuffer imageData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransparentViewState();
}

class _TransparentViewState extends ConsumerState<TransparentView> {
  bool isCapturing = false;
  late ScreenshotController screenshotController;
  String selectedMessage = DummyMessages.messages["Guest"]!;
static const double _kHeaderH = 64.0;

  // brand
  Brand selectedBrand = Brand.shaheen;

  // transformable image state
  late Rect rect;
  double rotationAngle = 0.0;
  late Offset center = const Offset(150, 150);
  double width = 100;
  double height = 100;

  String generateUniqueString() {
    final Random random = Random();
    final randomString =
        List.generate(10, (_) => random.nextInt(256).toRadixString(16)).join();
    final timestamp = DateFormat('yyyyMMddHHmmssSSS').format(DateTime.now());
    return '$timestamp-$randomString';
  }

  @override
  void initState() {
    super.initState();
    screenshotController = ScreenshotController();
    rect = Rect.fromCenter(center: center, width: width, height: height);
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List uint8list = Uint8List.view(widget.imageData);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff002147),
        foregroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 100,
        title: Column(
          children: [
            Image.asset("assets/logo.png", fit: BoxFit.contain, width: 100),
            Text(
              "Powered By StandardTouch",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // brand switcher (same UI as withbg_view)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: BrandSwitcher(
                value: selectedBrand,
                onChanged: (v) => setState(() => selectedBrand = v),
              ),
            ),

            // screenshot area — uses BrandShell for header/footer and injects the editor Stack in the middle
            Expanded(
              child: Center(
                child: Screenshot(
                  controller: screenshotController,
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: BrandShell(
                      brand: selectedBrand,
                      // the editable middle content
                     middle: LayoutBuilder(
  builder: (context, constraints) {
    final Size canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/bg.jpg', // or your brand-specific BG
            fit: BoxFit.cover,
          ),
        ),

        // Transformable user image on top
        Positioned.fill(
          child: TransformableBox(
            visibleHandles: isCapturing
                ? {}
                : {
                    HandlePosition.left,
                    HandlePosition.right,
                    HandlePosition.top,
                    HandlePosition.bottom,
                    HandlePosition.topLeft,
                    HandlePosition.bottomRight,
                    HandlePosition.topRight,
                    HandlePosition.bottomLeft,
                  },
            rect: rect,
            clampingRect: Offset.zero & canvasSize,
            onChanged: (result, event) {
              setState(() => rect = result.rect);
            },
            contentBuilder: (ctx, rect, flip) => Transform.rotate(
              angle: rotationAngle,
              child: Image.memory(
                uint8list,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // rotation controls
       if (!isCapturing)
  Positioned(
    top: _kHeaderH + 12, // <— move below header overlay
    left: 0,
    right: 0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundIcon(
          icon: Icons.rotate_left,
          onTap: () => setState(() => rotationAngle -= 0.1),
        ),
        const SizedBox(width: 8),
        _RoundIcon(
          icon: Icons.rotate_right,
          onTap: () => setState(() => rotationAngle += 0.1),
        ),
      ],
    ),
  ),
      ],
    );
  },
),

                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () {
          setState(() => isCapturing = true);
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (ctx) => ShaheenAlertDialog(
              widgetController: screenshotController,
              selectedMessage: selectedMessage,
              onMessageChanged: (message) =>
                  setState(() => selectedMessage = message ?? selectedMessage),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff002147),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        ),
        child: const Text("Share"),
      ),
    );
  }
}

/// Small circular icon button used for rotation controls
class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Reusable shell that draws brand header + footer and lets you inject any middle content.
/// This mirrors the look/feel of BrandCard but keeps the center editable.
class BrandShell extends StatelessWidget {
  const BrandShell({
    super.key,
    required this.brand,
    required this.middle,
    this.rounded = true,
    this.showInnerBorder = true,
  });

  final Brand brand;
  final Widget middle;
  final bool rounded;
  final bool showInnerBorder;

  @override
  Widget build(BuildContext context) {
    final radius = rounded ? 16.0 : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      elevation: 6,
      shadowColor: Colors.black26,
      // If you see any faint tint, uncomment the next two lines:
      // color: Colors.transparent,
      // surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1) MIDDLE CANVAS FILLS THE ENTIRE CARD
          Positioned.fill(child: middle),

          // 2) OPTIONAL THIN INNER BORDER
          if (showInnerBorder)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black.withOpacity(0.06), width: 1),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
            ),

          // 3) HEADER OVERLAY (IGNORED FOR POINTERS SO DRAG WORKS UNDER IT)
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                height: 64,
                width: double.infinity,
                color: brand.headerBg.withOpacity(brand == Brand.shaheen ? 1 : 0.96),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset(brand.logoAsset, fit: BoxFit.contain, height: 40),
                ),
              ),
            ),
          ),

          // 4) FOOTER OVERLAY (IGNORED FOR POINTERS SO DRAG WORKS UNDER IT)
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                width: double.infinity,
                color: brand.footerBg.withOpacity(brand == Brand.shaheen ? 1 : 0.96),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      child: Text(
                        brand.contact,
                        style: TextStyle(color: brand.footerFg, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, color: brand.footerFg, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            brand.domain,
                            style: TextStyle(color: brand.footerFg, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// withbg_view.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shaheen_selfie/components/dialog.dart';
import 'package:shaheen_selfie/screens/frames.dart';
import 'package:shaheen_selfie/utils/messages.dart';

final formKey = GlobalKey<FormState>();

// enum Brand { shaheen, bbf }

class WithbgView extends ConsumerStatefulWidget {
  const WithbgView({super.key, required this.imageData});
  final ByteBuffer imageData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WithbgViewState();
}

class _WithbgViewState extends ConsumerState<WithbgView> {
  bool isCapturing = false;
  late ScreenshotController screenshotController;
  String selectedMessage = DummyMessages.messages["Guest"]!;
  Brand selectedBrand = Brand.shaheen; // default

  @override
  void initState() {
    super.initState();
    screenshotController = ScreenshotController();
  }

  @override

  Widget build(BuildContext context) {
    final Uint8List uint8list = Uint8List.view(widget.imageData);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff002147),
        foregroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 88,
        title: Column(
          children: [
            Image.asset("assets/logo.png", width: 92, fit: BoxFit.contain),
            const SizedBox(height: 4),
            Text(
              "Powered By StandardTouch",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Compact segmented switch
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: _BrandSwitcher(
                value: selectedBrand,
                onChanged: (v) => setState(() => selectedBrand = v),
              ),
            ),

            // Screenshot area
            Expanded(
              child: Center(
                child: Screenshot(
                  controller: screenshotController,
                  child: AspectRatio(
                    aspectRatio: 4 / 5, // consistent portrait canvas
                    child: BrandCard(
                      brand: selectedBrand,
                      photoBytes: uint8list,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ElevatedButton(
          onPressed: () {
            setState(() => isCapturing = true);
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (ctx) => ShaheenAlertDialog(
                widgetController: screenshotController,
                onMessageChanged: (message) {
                  setState(() => selectedMessage = message ?? selectedMessage);
                },
                selectedMessage: selectedMessage,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff002147),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          ),
          child: const Text("Share"),
        ),
      ),
    );
  }
}


class _BrandSwitcher extends StatelessWidget {
  const _BrandSwitcher({required this.value, required this.onChanged});

  final Brand value;
  final ValueChanged<Brand> onChanged;

  @override
  Widget build(BuildContext context) {
    final isShaheen = value == Brand.shaheen;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _Pill(
              label: "Shaheen",
              selected: isShaheen,
              onTap: () => onChanged(Brand.shaheen),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _Pill(
              label: "BBF",
              selected: !isShaheen,
              onTap: () => onChanged(Brand.bbf),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xff002147) : Colors.transparent;
    final fg = selected ? Colors.white : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
      ),
    );
  }
}


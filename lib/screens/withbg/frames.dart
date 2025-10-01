
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shaheen_selfie/screens/withbg/withbg_view.dart';

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


class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.brand, required this.photoBytes});

  final Brand brand;
  final Uint8List photoBytes;

  // palette
  Color get _primary =>
      brand == Brand.shaheen ? const Color(0xff002147) : const Color(0xff02a859);
  Color get _headerBg =>
      brand == Brand.shaheen ? const Color(0xff002147) : const Color(0xffF4F5F7);
  Color get _footerBg =>
      brand == Brand.shaheen ? const Color(0xff002147) : const Color(0xffF4F5F7);
  Color get _footerFg =>
      brand == Brand.shaheen ? Colors.white : const Color(0xff02a859);
  String get _domain =>
      brand == Brand.shaheen ? "shaheengroup.org" : "bidarbettermentfoundation.org";
  String get _contact =>
      brand == Brand.shaheen ? "Toll Free No: 18001216235" : "Contact No: 9448965656";
  String get _logoAsset =>
      brand == Brand.shaheen ? "assets/logo.png" : "assets/bbflogo.png";

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // background photo
          Positioned.fill(
            child: Image.memory(photoBytes, fit: BoxFit.cover),
          ),

          // top header bar (solid for Shaheen, light for BBF)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 64,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _headerBg.withOpacity(brand == Brand.shaheen ? 1 : 0.96),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset(
                    _logoAsset,
                    fit: BoxFit.contain,
                    height: 40,
                  ),
                ),
              ),
            ),
          ),

          // subtle inner border to separate from screen background
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.06), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          // bottom footer info
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _footerBg.withOpacity(brand == Brand.shaheen ? 1 : 0.96),
              ),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    child: Text(
                      _contact,
                      style: TextStyle(
                        color: _footerFg,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    child: Row(
                      children: [
                        Icon(Icons.public, color: _footerFg, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _domain,
                          style: TextStyle(
                            color: _footerFg,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // rounded corner mask already handled by Card.clipBehavior
        ],
      ),
    );
  }
}

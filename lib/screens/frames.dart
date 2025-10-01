import 'dart:typed_data';

import 'package:flutter/material.dart';

enum Brand { shaheen, bbf }

extension BrandX on Brand {
  String get label => this == Brand.shaheen ? "Shaheen" : "BBF";

  // assets
  String get logoAsset =>
      this == Brand.shaheen ? "assets/logo.png" : "assets/bbflogo.png";

  // contact & domain
  String get contact =>
      this == Brand.shaheen ? "Toll Free No: 18001216235" : "Contact No: 9448965656";

  String get domain =>
      this == Brand.shaheen ? "shaheengroup.org" : "bidarbettermentfoundation.org";

  // colors
  Color get primary =>
      this == Brand.shaheen ? const Color(0xff002147) : const Color(0xff02a859);

  Color get headerBg =>
      this == Brand.shaheen ? const Color(0xff002147) : const Color(0xffF4F5F7);

  Color get footerBg =>
      this == Brand.shaheen ? const Color(0xff002147) : const Color(0xffF4F5F7);

  Color get footerFg =>
      this == Brand.shaheen ? Colors.white : const Color(0xff02a859);
}




class BrandSwitcher extends StatelessWidget {
  const BrandSwitcher({
    super.key,
    required this.value,
    required this.onChanged,
  });

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
              label: Brand.shaheen.label,
              selected: isShaheen,
              selectedColor: Brand.shaheen.primary, // navy
              onTap: () => onChanged(Brand.shaheen),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _Pill(
              label: Brand.bbf.label,
              selected: !isShaheen,
              selectedColor: Brand.shaheen.primary, // keep same UI color
              onTap: () => onChanged(Brand.bbf),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? selectedColor : Colors.transparent;
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




class BrandCard extends StatelessWidget {
  const BrandCard({
    super.key,
    required this.brand,
    required this.photoBytes,
  });

  final Brand brand;
  final Uint8List photoBytes;

  @override
  Widget build(BuildContext context) {
    const radius = 16.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // background photo
          Positioned.fill(child: Image.memory(photoBytes, fit: BoxFit.cover)),

          // header
          Align(
            alignment: Alignment.topCenter,
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

          // thin inner border
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

          // footer
          Align(
            alignment: Alignment.bottomCenter,
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
        ],
      ),
    );
  }
}

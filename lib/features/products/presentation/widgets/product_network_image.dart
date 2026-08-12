import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ProductNetworkImage extends StatelessWidget {
  const ProductNetworkImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _unavailablePlaceholder(context);

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => const InterCommerceShimmerBox(),
      errorWidget: (context, url, error) => _unavailablePlaceholder(context),
    );
  }

  /// `InterCommerceImagePlaceholder` is sized for a full product-detail
  /// image, not a ~150px grid thumbnail — the offline/broken-image case
  /// (every card at once, all showing the same placeholder) is exactly
  /// where that mismatch shows up as a real layout overflow, not just a
  /// theoretical one. `FittedBox` shrinks it to whatever room the slot
  /// actually has instead of assuming one fixed context.
  Widget _unavailablePlaceholder(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: InterCommerceImagePlaceholder(
        title: AppLocalizations.of(context)!.catalogImageUnavailable,
      ),
    );
  }
}

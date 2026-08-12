import 'package:flutter/material.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ProductNetworkImage extends StatelessWidget {
  const ProductNetworkImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return InterCommerceImagePlaceholder(
        title: AppLocalizations.of(context)!.catalogImageUnavailable,
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const InterCommerceShimmerBox();
      },
      errorBuilder: (context, error, stackTrace) => InterCommerceImagePlaceholder(
        title: AppLocalizations.of(context)!.catalogImageUnavailable,
      ),
    );
  }
}

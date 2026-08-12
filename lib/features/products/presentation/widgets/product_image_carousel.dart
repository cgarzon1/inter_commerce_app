import 'package:flutter/material.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import 'product_network_image.dart';


class ProductImageCarousel extends StatefulWidget {
  const ProductImageCarousel({super.key, required this.images, this.height = 420});

  final List<String> images;
  final double height;

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.isEmpty ? const [''] : widget.images;

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) => ProductNetworkImage(url: images[index]),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: InterCommerceSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: InterCommerceDurations.fast,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: i == _page ? 14 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(InterCommerceRadius.pill),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:equatable/equatable.dart';

/// Business object for a product. Pure Dart, no JSON, no Flutter — this is
/// what Domain and Presentation work with. The Data layer's `ProductModel`
class Product extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String sku;
  final String availabilityStatus;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.availabilityStatus,
    required this.thumbnail,
    required this.images,
  });

  /// Final unit price once [discountPercentage] is applied.
  double get discountedPrice => price - (price * discountPercentage / 100);

  bool get isInStock => stock > 0;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        price,
        discountPercentage,
        rating,
        stock,
        tags,
        brand,
        sku,
        availabilityStatus,
        thumbnail,
        images,
      ];
}

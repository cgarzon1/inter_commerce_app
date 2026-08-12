import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/product.dart';

/// Data Transfer Object for a single product from DummyJSON. It IS-A
/// [Product] (so the rest of the app can keep using the domain entity)
/// plus the JSON (de)serialization that Domain must never know about.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.tags,
    required super.brand,
    required super.sku,
    required super.availabilityStatus,
    required super.thumbnail,
    required super.images,
  });

  factory ProductModel.fromJson(JSON json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: json['stock'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      brand: json['brand'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      availabilityStatus: json['availabilityStatus'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }

  JSON toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'sku': sku,
      'availabilityStatus': availabilityStatus,
      'thumbnail': thumbnail,
      'images': images,
    };
  }
}

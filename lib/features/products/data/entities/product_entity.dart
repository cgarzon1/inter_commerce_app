import 'package:objectbox/objectbox.dart';

import '../../domain/entities/product.dart';

@Entity()
class ProductEntity {
  @Id(assignable: true)
  int id;

  String title;
  String description;
  String category;
  double price;
  double discountPercentage;
  double rating;
  int stock;
  List<String> tags;
  String brand;
  String sku;
  String availabilityStatus;
  String thumbnail;
  List<String> images;

  ProductEntity({
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

  Product toDomain() => Product(
        id: id,
        title: title,
        description: description,
        category: category,
        price: price,
        discountPercentage: discountPercentage,
        rating: rating,
        stock: stock,
        tags: tags,
        brand: brand,
        sku: sku,
        availabilityStatus: availabilityStatus,
        thumbnail: thumbnail,
        images: images,
      );

  /// Takes the domain [Product], not `ProductModel` — every field it
  /// needs already lives on the entity, and a domain type sidesteps the
  /// same list-covariance footgun `ProductRepositoryImpl.getCategories`
  /// already ran into (a `List<Product>` from a `PaginatedProductsModel`
  /// stays a `List<Product>` at the static-type level even though every
  /// element is really a `ProductModel`).
  factory ProductEntity.fromDomain(Product product) => ProductEntity(
        id: product.id,
        title: product.title,
        description: product.description,
        category: product.category,
        price: product.price,
        discountPercentage: product.discountPercentage,
        rating: product.rating,
        stock: product.stock,
        tags: product.tags,
        brand: product.brand,
        sku: product.sku,
        availabilityStatus: product.availabilityStatus,
        thumbnail: product.thumbnail,
        images: product.images,
      );
}

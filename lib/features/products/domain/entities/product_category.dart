import 'package:equatable/equatable.dart';

/// One entry from `GET /products/categories` — the full, fixed list of

class ProductCategory extends Equatable {
  final String slug;
  final String name;

  const ProductCategory({required this.slug, required this.name});

  @override
  List<Object?> get props => [slug, name];
}

import 'package:objectbox/objectbox.dart';

import '../../domain/entities/product_category.dart';
import '../models/product_category_model.dart';

@Entity()
class ProductCategoryEntity {
  @Id()
  int id;

  @Unique(onConflict: ConflictStrategy.replace)
  String slug;

  String name;

  ProductCategoryEntity({
    this.id = 0,
    required this.slug,
    required this.name,
  });

  ProductCategory toDomain() => ProductCategory(slug: slug, name: name);

  factory ProductCategoryEntity.fromModel(ProductCategoryModel model) =>
      ProductCategoryEntity(slug: model.slug, name: model.name);
}

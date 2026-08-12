import '../../../../core/persistence/objectbox_store.dart';
import '../../../../objectbox.g.dart';
import '../../domain/entities/product.dart';
import '../entities/product_category_entity.dart';
import '../entities/product_entity.dart';
import '../models/product_category_model.dart';

abstract class ProductLocalDataSource {
  void cacheProducts(List<Product> products);

  void cacheProduct(Product product);

  void cacheCategories(List<ProductCategoryModel> categories);

  List<ProductEntity> getCachedProducts({required int limit, required int skip});

  List<ProductEntity> getCachedProductsByCategory(
    String category, {
    required int limit,
    required int skip,
  });

  ProductEntity? getCachedProductById(int id);

  List<ProductCategoryEntity> getCachedCategories();

  int countCachedProducts();

  int countCachedProductsByCategory(String category);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  ProductLocalDataSourceImpl(ObjectBoxStore objectBox)
      : _products = objectBox.store.box<ProductEntity>(),
        _categories = objectBox.store.box<ProductCategoryEntity>();

  final Box<ProductEntity> _products;
  final Box<ProductCategoryEntity> _categories;

  @override
  void cacheProducts(List<Product> products) {
    _products.putMany(products.map(ProductEntity.fromDomain).toList());
  }

  @override
  void cacheProduct(Product product) {
    _products.put(ProductEntity.fromDomain(product));
  }

  @override
  void cacheCategories(List<ProductCategoryModel> categories) {
    _categories.removeAll();
    _categories.putMany(categories.map(ProductCategoryEntity.fromModel).toList());
  }

  @override
  List<ProductEntity> getCachedProducts({required int limit, required int skip}) {
    return _sortedById(_products.getAll()).skip(skip).take(limit).toList();
  }

  @override
  List<ProductEntity> getCachedProductsByCategory(
    String category, {
    required int limit,
    required int skip,
  }) {
    final query = _products.query(ProductEntity_.category.equals(category)).build();
    try {
      return _sortedById(query.find()).skip(skip).take(limit).toList();
    } finally {
      query.close();
    }
  }

  @override
  ProductEntity? getCachedProductById(int id) => _products.get(id);

  @override
  List<ProductCategoryEntity> getCachedCategories() => _categories.getAll();

  @override
  int countCachedProducts() => _products.count();

  @override
  int countCachedProductsByCategory(String category) {
    final query = _products.query(ProductEntity_.category.equals(category)).build();
    try {
      return query.count();
    } finally {
      query.close();
    }
  }

  List<ProductEntity> _sortedById(List<ProductEntity> entities) =>
      entities..sort((a, b) => a.id.compareTo(b.id));
}

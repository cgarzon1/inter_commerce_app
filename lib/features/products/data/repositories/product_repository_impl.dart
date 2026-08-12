import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/paginated_products.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/paginated_products_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  ResultFuture<PaginatedProducts> getProducts({
    required int limit,
    required int skip,
  }) {
    return _fetchOrServeCache(
      fetchRemote: () => remoteDataSource.getProducts(limit: limit, skip: skip),
      cachedPage: () => _cachedPage(limit: limit, skip: skip),
    );
  }

  @override
  ResultFuture<PaginatedProducts> getProductsByCategory({
    required String category,
    required int limit,
    required int skip,
  }) {
    return _fetchOrServeCache(
      fetchRemote: () => remoteDataSource.getProductsByCategory(category: category, limit: limit, skip: skip),
      cachedPage: () => _cachedPage(category: category, limit: limit, skip: skip),
    );
  }

  @override
  ResultFuture<PaginatedProducts> searchProducts({
    required String query,
    required int limit,
    required int skip,
  }) {
    // Deliberately not cached: search isn't wired to any screen yet
    // (the "Buscar" tab is still a placeholder), so there's no offline
    // experience to build for it until it exists.
    return _guard(
      () => remoteDataSource.searchProducts(query: query, limit: limit, skip: skip),
    );
  }

  @override
  ResultFuture<Product> getProductById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final product = await remoteDataSource.getProductById(id);
        localDataSource.cacheProduct(product);
        return Right(product);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    }

    final cached = localDataSource.getCachedProductById(id);
    if (cached == null) return const Left(NetworkFailure());
    return Right(cached.toDomain());
  }

  @override
  ResultFuture<List<ProductCategory>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getCategories();
        localDataSource.cacheCategories(categories);
        return Right(List<ProductCategory>.of(categories));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    }

    final cached = localDataSource.getCachedCategories().map((e) => e.toDomain()).toList();
    if (cached.isEmpty) return const Left(NetworkFailure());
    return Right(List<ProductCategory>.of(cached));
  }

  /// Shared shape for [getProducts] and [getProductsByCategory]: online,
  /// fetch fresh and cache it for later; offline, serve whatever's
  /// cached instead of failing outright — only a truly empty cache
  /// (e.g. first-ever launch with no connectivity) still returns
  /// [NetworkFailure].
  Future<Either<Failure, PaginatedProducts>> _fetchOrServeCache({
    required Future<PaginatedProductsModel> Function() fetchRemote,
    required PaginatedProducts Function() cachedPage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final page = await fetchRemote();
        localDataSource.cacheProducts(page.products);
        return Right(page);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    }

    final page = cachedPage();
    if (page.products.isEmpty) return const Left(NetworkFailure());
    return Right(page);
  }

  PaginatedProducts _cachedPage({String? category, required int limit, required int skip}) {
    final entities = category == null
        ? localDataSource.getCachedProducts(limit: limit, skip: skip)
        : localDataSource.getCachedProductsByCategory(category, limit: limit, skip: skip);
    final total = category == null
        ? localDataSource.countCachedProducts()
        : localDataSource.countCachedProductsByCategory(category);

    return PaginatedProducts(
      products: List.of(entities.map((e) => e.toDomain())),
      total: total,
      skip: skip,
      limit: limit,
      isFromCache: true,
    );
  }

  /// Plumbing for the one method that still doesn't have an offline
  /// path ([searchProducts]): check connectivity first, map any
  /// [ServerException] to a [ServerFailure].
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await call();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}

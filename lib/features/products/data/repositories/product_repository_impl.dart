import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/paginated_products.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';


class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  ResultFuture<PaginatedProducts> getProducts({
    required int limit,
    required int skip,
  }) {
    return _guard(() => remoteDataSource.getProducts(limit: limit, skip: skip));
  }

  @override
  ResultFuture<PaginatedProducts> searchProducts({
    required String query,
    required int limit,
    required int skip,
  }) {
    return _guard(
      () => remoteDataSource.searchProducts(query: query, limit: limit, skip: skip),
    );
  }

  @override
  ResultFuture<PaginatedProducts> getProductsByCategory({
    required String category,
    required int limit,
    required int skip,
  }) {
    return _guard(
      () => remoteDataSource.getProductsByCategory(category: category, limit: limit, skip: skip),
    );
  }

  @override
  ResultFuture<Product> getProductById(int id) {
    return _guard(() => remoteDataSource.getProductById(id));
  }

  @override
  ResultFuture<List<ProductCategory>> getCategories() {

    return _guard(() async {
      final models = await remoteDataSource.getCategories();
      return List<ProductCategory>.of(models);
    });
  }

  /// Shared plumbing for every method above: check connectivity first,
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

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/paginated_products.dart';
import '../repositories/product_repository.dart';

/// Searches the catalog by free-text query (`GET /products/search?q=`).
class SearchProducts implements UseCase<PaginatedProducts, SearchProductsParams> {
  final ProductRepository repository;

  const SearchProducts(this.repository);

  @override
  ResultFuture<PaginatedProducts> call(SearchProductsParams params) {
    final query = params.query.trim();
    if (query.isEmpty) {
      return Future.value(
        const Left(ValidationFailure('El término de búsqueda no puede estar vacío')),
      );
    }

    return repository.searchProducts(
      query: query,
      limit: params.limit,
      skip: params.skip,
    );
  }
}

class SearchProductsParams extends Equatable {
  final String query;
  final int limit;
  final int skip;

  const SearchProductsParams({
    required this.query,
    this.limit = ApiConstants.defaultPageLimit,
    this.skip = 0,
  });

  @override
  List<Object?> get props => [query, limit, skip];
}

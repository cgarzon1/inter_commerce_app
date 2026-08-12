import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/paginated_products.dart';
import '../repositories/product_repository.dart';

/// Fetches one page of the product catalog (`Catálogo — Discovery`,
/// scroll infinito en lotes).
class GetProducts implements UseCase<PaginatedProducts, GetProductsParams> {
  final ProductRepository repository;

  const GetProducts(this.repository);

  @override
  ResultFuture<PaginatedProducts> call(GetProductsParams params) {
    return repository.getProducts(limit: params.limit, skip: params.skip);
  }
}

class GetProductsParams extends Equatable {
  final int limit;
  final int skip;

  const GetProductsParams({
    this.limit = ApiConstants.defaultPageLimit,
    this.skip = 0,
  });

  @override
  List<Object?> get props => [limit, skip];
}

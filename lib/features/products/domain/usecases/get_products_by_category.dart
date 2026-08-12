import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/paginated_products.dart';
import '../repositories/product_repository.dart';


/// client-side filter over [GetProducts]'s results, so a category the
class GetProductsByCategory implements UseCase<PaginatedProducts, GetProductsByCategoryParams> {
  final ProductRepository repository;

  const GetProductsByCategory(this.repository);

  @override
  ResultFuture<PaginatedProducts> call(GetProductsByCategoryParams params) {
    return repository.getProductsByCategory(
      category: params.category,
      limit: params.limit,
      skip: params.skip,
    );
  }
}

class GetProductsByCategoryParams extends Equatable {
  final String category;
  final int limit;
  final int skip;

  const GetProductsByCategoryParams({
    required this.category,
    this.limit = ApiConstants.defaultPageLimit,
    this.skip = 0,
  });

  @override
  List<Object?> get props => [category, limit, skip];
}

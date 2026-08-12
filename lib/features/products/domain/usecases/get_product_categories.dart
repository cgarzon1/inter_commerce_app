import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

/// Fetches the full category list, for the catalog's filter chips.
class GetProductCategories implements UseCase<List<ProductCategory>, NoParams> {
  final ProductRepository repository;

  const GetProductCategories(this.repository);

  @override
  ResultFuture<List<ProductCategory>> call(NoParams params) {
    return repository.getCategories();
  }
}

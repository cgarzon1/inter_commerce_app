import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Fetches a single product (`Detalle de producto — Conversion`).
class GetProductDetail implements UseCase<Product, GetProductDetailParams> {
  final ProductRepository repository;

  const GetProductDetail(this.repository);

  @override
  ResultFuture<Product> call(GetProductDetailParams params) {
    return repository.getProductById(params.id);
  }
}

class GetProductDetailParams extends Equatable {
  final int id;

  const GetProductDetailParams(this.id);

  @override
  List<Object?> get props => [id];
}

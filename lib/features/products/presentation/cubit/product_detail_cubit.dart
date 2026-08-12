import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_detail.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({required this.getProductDetail}) : super(const ProductDetailState());

  final GetProductDetail getProductDetail;

  Future<void> load(int id, {Product? initial}) async {
    emit(ProductDetailState(
      status: initial != null ? ProductDetailStatus.loaded : ProductDetailStatus.loading,
      product: initial,
    ));

    final result = await getProductDetail(GetProductDetailParams(id));
    result.fold(
      (failure) => emit(state.copyWith(
        status: state.product != null ? ProductDetailStatus.loaded : ProductDetailStatus.error,
        failure: state.product != null ? null : failure,
      )),
      (product) => emit(ProductDetailState(
        status: ProductDetailStatus.loaded,
        product: product,
      )),
    );
  }
}

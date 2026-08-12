import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_detail.dart';
import 'product_detail_state.dart';

/// Drives the product detail screen (B.1–B.3 in the design spec).
///
/// Only talks to [GetProductDetail] — never to a repository or
/// datasource directly, per the architecture rules.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({required this.getProductDetail}) : super(const ProductDetailState());

  final GetProductDetail getProductDetail;

  /// [initial] is the [Product] the user already tapped from the
  /// catalog, if any — shown immediately while this fetches the
  /// canonical detail in the background (see [ProductDetailState]).
  Future<void> load(int id, {Product? initial}) async {
    emit(ProductDetailState(
      status: initial != null ? ProductDetailStatus.loaded : ProductDetailStatus.loading,
      product: initial,
    ));

    final result = await getProductDetail(GetProductDetailParams(id));
    result.fold(
      (failure) => emit(state.copyWith(
        // With nothing to show yet, this is a real failure; with an
        // `initial` product already on screen, keep showing it and
        // just drop the failed background refresh silently.
        status: state.product != null ? ProductDetailStatus.loaded : ProductDetailStatus.error,
        failure: state.product != null ? null : failure,
      )),
      (product) => emit(ProductDetailState(
        status: ProductDetailStatus.loaded,
        product: product,
        isSaved: state.isSaved,
      )),
    );
  }

  /// Local-only for now — no persistence layer exists yet, so this
  /// resets on app restart. Revisit once a "favorites"/account feature
  /// is in scope.
  void toggleSaved() => emit(state.copyWith(isSaved: !state.isSaved));
}

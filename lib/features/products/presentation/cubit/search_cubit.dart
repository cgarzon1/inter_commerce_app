import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/search_products.dart';
import 'search_state.dart';


class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required this.searchProducts}) : super(const SearchState());

  final SearchProducts searchProducts;

  static const _debounceDelay = Duration(milliseconds: 400);
  Timer? _debounce;

  void queryChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(state.copyWith(query: query));
    _debounce = Timer(_debounceDelay, () => _search(query));
  }

  void retry() {
    _debounce?.cancel();
    if (state.query.trim().isEmpty) return;
    _search(state.query);
  }

  Future<void> _search(String query) async {
    emit(state.copyWith(status: SearchStatus.loading, query: query));

    final result = await searchProducts(SearchProductsParams(query: query));
    result.fold(
      (failure) => emit(state.copyWith(status: SearchStatus.error, failure: failure)),
      (page) => emit(state.copyWith(status: SearchStatus.loaded, results: page.products)),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

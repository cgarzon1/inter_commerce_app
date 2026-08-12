import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';

enum SearchStatus { initial, loading, loaded, error }


class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.failure,
  });

  final SearchStatus status;
  final String query;
  final List<Product> results;
  final Failure? failure;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Product>? results,
    Failure? failure,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, query, results, failure];
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inter_commerce_app/core/error/failures.dart';
import 'package:inter_commerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:inter_commerce_app/features/products/domain/usecases/search_products.dart';
import 'package:mocktail/mocktail.dart';

import '../../product_fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;
  late SearchProducts useCase;

  setUp(() {
    repository = MockProductRepository();
    useCase = SearchProducts(repository);
  });

  test('devuelve ValidationFailure sin tocar el repository cuando el query está vacío', () async {
    final result = await useCase(const SearchProductsParams(query: ''));

    expect(result, const Left(ValidationFailure('El término de búsqueda no puede estar vacío')));
    verifyZeroInteractions(repository);
  });

  test('devuelve ValidationFailure cuando el query es solo espacios', () async {
    final result = await useCase(const SearchProductsParams(query: '   '));

    expect(result.isLeft(), isTrue);
    verifyZeroInteractions(repository);
  });

  test('recorta espacios y delega en repository.searchProducts con el query limpio', () async {
    when(() => repository.searchProducts(query: 'phone', limit: 10, skip: 0))
        .thenAnswer((_) async => Right(tPaginatedProducts()));

    final result = await useCase(const SearchProductsParams(query: '  phone  '));

    expect(result, Right(tPaginatedProducts()));
    verify(() => repository.searchProducts(query: 'phone', limit: 10, skip: 0)).called(1);
  });

  test('propaga el Failure cuando el repository falla', () async {
    when(() => repository.searchProducts(
          query: any(named: 'query'),
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
        )).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await useCase(const SearchProductsParams(query: 'phone'));

    expect(result, const Left(ServerFailure()));
  });
}

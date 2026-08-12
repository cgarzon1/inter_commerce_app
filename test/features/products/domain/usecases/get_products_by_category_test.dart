import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inter_commerce_app/core/error/failures.dart';
import 'package:inter_commerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:inter_commerce_app/features/products/domain/usecases/get_products_by_category.dart';
import 'package:mocktail/mocktail.dart';

import '../../product_fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;
  late GetProductsByCategory useCase;

  setUp(() {
    repository = MockProductRepository();
    useCase = GetProductsByCategory(repository);
  });

  test('delega en repository.getProductsByCategory con la categoría, limit y skip recibidos', () async {
    when(() => repository.getProductsByCategory(category: 'beauty', limit: 10, skip: 0))
        .thenAnswer((_) async => Right(tPaginatedProducts()));

    final result = await useCase(const GetProductsByCategoryParams(category: 'beauty'));

    expect(result, Right(tPaginatedProducts()));
    verify(() => repository.getProductsByCategory(category: 'beauty', limit: 10, skip: 0)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('propaga el Failure cuando el repository falla', () async {
    when(() => repository.getProductsByCategory(
          category: any(named: 'category'),
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
        )).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await useCase(const GetProductsByCategoryParams(category: 'beauty'));

    expect(result, const Left(ServerFailure()));
  });
}

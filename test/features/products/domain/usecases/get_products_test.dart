import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inter_commerce_app/core/constants/app_constants.dart';
import 'package:inter_commerce_app/core/error/failures.dart';
import 'package:inter_commerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:inter_commerce_app/features/products/domain/usecases/get_products.dart';
import 'package:mocktail/mocktail.dart';

import '../../product_fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;
  late GetProducts useCase;

  setUp(() {
    repository = MockProductRepository();
    useCase = GetProducts(repository);
  });

  test('delega en repository.getProducts con el limit/skip recibidos y devuelve su resultado', () async {
    when(() => repository.getProducts(limit: 20, skip: 40))
        .thenAnswer((_) async => Right(tPaginatedProducts()));

    final result = await useCase(const GetProductsParams(limit: 20, skip: 40));

    expect(result, Right(tPaginatedProducts()));
    verify(() => repository.getProducts(limit: 20, skip: 40)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('usa limit/skip por defecto cuando GetProductsParams no los recibe', () async {
    when(() => repository.getProducts(limit: any(named: 'limit'), skip: any(named: 'skip')))
        .thenAnswer((_) async => Right(tPaginatedProducts()));

    await useCase(const GetProductsParams());

    verify(() => repository.getProducts(limit: ApiConstants.defaultPageLimit, skip: 0)).called(1);
  });

  test('propaga el Failure cuando el repository falla', () async {
    when(() => repository.getProducts(limit: any(named: 'limit'), skip: any(named: 'skip')))
        .thenAnswer((_) async => const Left(ServerFailure()));

    final result = await useCase(const GetProductsParams());

    expect(result, const Left(ServerFailure()));
  });
}

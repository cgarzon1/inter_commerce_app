import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inter_commerce_app/core/error/failures.dart';
import 'package:inter_commerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:inter_commerce_app/features/products/domain/usecases/get_product_detail.dart';
import 'package:mocktail/mocktail.dart';

import '../../product_fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;
  late GetProductDetail useCase;

  setUp(() {
    repository = MockProductRepository();
    useCase = GetProductDetail(repository);
  });

  test('delega en repository.getProductById con el id recibido y devuelve su resultado', () async {
    when(() => repository.getProductById(1)).thenAnswer((_) async => const Right(tProduct));

    final result = await useCase(const GetProductDetailParams(1));

    expect(result, const Right(tProduct));
    verify(() => repository.getProductById(1)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('propaga el Failure cuando el producto no existe', () async {
    when(() => repository.getProductById(any())).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await useCase(const GetProductDetailParams(999));

    expect(result, const Left(ServerFailure()));
  });
}

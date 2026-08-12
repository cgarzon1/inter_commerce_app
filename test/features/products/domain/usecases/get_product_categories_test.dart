import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inter_commerce_app/core/error/failures.dart';
import 'package:inter_commerce_app/core/usecases/usecase.dart';
import 'package:inter_commerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:inter_commerce_app/features/products/domain/usecases/get_product_categories.dart';
import 'package:mocktail/mocktail.dart';

import '../../product_fixtures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;
  late GetProductCategories useCase;

  setUp(() {
    repository = MockProductRepository();
    useCase = GetProductCategories(repository);
  });

  test('delega en repository.getCategories y devuelve su resultado', () async {
    when(() => repository.getCategories()).thenAnswer((_) async => const Right([tProductCategory]));

    final result = await useCase(const NoParams());

    expect(result, const Right([tProductCategory]));
    verify(() => repository.getCategories()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('propaga el Failure cuando el repository falla', () async {
    when(() => repository.getCategories()).thenAnswer((_) async => const Left(ServerFailure()));

    final result = await useCase(const NoParams());

    expect(result, const Left(ServerFailure()));
  });
}

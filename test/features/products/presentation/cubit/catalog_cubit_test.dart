import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inter_commerce_app/core/error/failures.dart';
import 'package:inter_commerce_app/core/usecases/usecase.dart';
import 'package:inter_commerce_app/features/products/domain/entities/paginated_products.dart';
import 'package:inter_commerce_app/features/products/domain/usecases/get_product_categories.dart';
import 'package:inter_commerce_app/features/products/domain/usecases/get_products.dart';
import 'package:inter_commerce_app/features/products/domain/usecases/get_products_by_category.dart';
import 'package:inter_commerce_app/features/products/presentation/cubit/catalog_cubit.dart';
import 'package:inter_commerce_app/features/products/presentation/cubit/catalog_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../product_fixtures.dart';

class MockGetProducts extends Mock implements GetProducts {}

class MockGetProductsByCategory extends Mock implements GetProductsByCategory {}

class MockGetProductCategories extends Mock implements GetProductCategories {}

void main() {
  late MockGetProducts getProducts;
  late MockGetProductsByCategory getProductsByCategory;
  late MockGetProductCategories getCategories;

  setUpAll(() {
    // Fallback para los `any()` usados con argumentos no-primitivos.
    registerFallbackValue(const GetProductsParams());
    registerFallbackValue(const GetProductsByCategoryParams(category: 'beauty'));
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getProducts = MockGetProducts();
    getProductsByCategory = MockGetProductsByCategory();
    getCategories = MockGetProductCategories();
  });

  CatalogCubit buildCubit() => CatalogCubit(
        getProducts: getProducts,
        getProductsByCategory: getProductsByCategory,
        getCategories: getCategories,
      );

  group('loadInitial', () {
    blocTest<CatalogCubit, CatalogState>(
      'emite [loading, loaded] con los productos y categorías cuando ambas llamadas responden bien',
      setUp: () {
        when(() => getProducts(any())).thenAnswer((_) async => Right(tPaginatedProducts()));
        when(() => getCategories(any())).thenAnswer((_) async => const Right([tProductCategory]));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const CatalogState(status: CatalogStatus.loading),
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          categories: const [tProductCategory],
          hasMore: false,
          isOffline: false,
        ),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'degrada a categorías vacías (sin fallar todo el catálogo) si getCategories falla',
      setUp: () {
        when(() => getProducts(any())).thenAnswer((_) async => Right(tPaginatedProducts()));
        when(() => getCategories(any())).thenAnswer((_) async => const Left(ServerFailure()));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const CatalogState(status: CatalogStatus.loading),
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          categories: const [],
          hasMore: false,
          isOffline: false,
        ),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'emite [loading, error] cuando getProducts falla',
      setUp: () {
        when(() => getProducts(any())).thenAnswer((_) async => const Left(NetworkFailure()));
        when(() => getCategories(any())).thenAnswer((_) async => const Right([tProductCategory]));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const CatalogState(status: CatalogStatus.loading),
        const CatalogState(status: CatalogStatus.error, failure: NetworkFailure()),
      ],
    );

    blocTest<CatalogCubit, CatalogState>(
      'marca isOffline cuando la página viene de cache (isFromCache)',
      setUp: () {
        when(() => getProducts(any()))
            .thenAnswer((_) async => Right(tPaginatedProducts(isFromCache: true)));
        when(() => getCategories(any())).thenAnswer((_) async => const Right([tProductCategory]));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const CatalogState(status: CatalogStatus.loading),
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          categories: const [tProductCategory],
          hasMore: false,
          isOffline: true,
        ),
      ],
    );
  });

  group('loadMore', () {
    blocTest<CatalogCubit, CatalogState>(
      'no hace nada si el catálogo no está en estado loaded',
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      expect: () => <CatalogState>[],
      verify: (_) {
        verifyZeroInteractions(getProducts);
      },
    );

    blocTest<CatalogCubit, CatalogState>(
      'anexa la siguiente página sin perder los productos ya cargados',
      seed: () => CatalogState(
        status: CatalogStatus.loaded,
        products: const [tProduct],
        hasMore: true,
      ),
      setUp: () {
        when(() => getProducts(any())).thenAnswer(
          (_) async => Right(PaginatedProducts(
            products: const [tProduct],
            total: 2,
            skip: 10,
            limit: 10,
          )),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          hasMore: true,
          isLoadingMore: true,
        ),
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct, tProduct],
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(() => getProducts(const GetProductsParams(skip: 10))).called(1);
      },
    );

    blocTest<CatalogCubit, CatalogState>(
      'marca isOffline y apaga isLoadingMore cuando la página siguiente falla por red',
      seed: () => CatalogState(
        status: CatalogStatus.loaded,
        products: const [tProduct],
        hasMore: true,
      ),
      setUp: () {
        when(() => getProducts(any())).thenAnswer((_) async => const Left(NetworkFailure()));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      expect: () => [
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          hasMore: true,
          isLoadingMore: true,
        ),
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          hasMore: true,
          isLoadingMore: false,
          isOffline: true,
        ),
      ],
    );
  });

  group('selectCategory', () {
    blocTest<CatalogCubit, CatalogState>(
      'filtra por la categoría elegida y reinicia la paginación',
      seed: () => CatalogState(
        status: CatalogStatus.loaded,
        products: const [tProduct],
        categories: const [tProductCategory],
        hasMore: false,
      ),
      setUp: () {
        when(() => getProductsByCategory(any()))
            .thenAnswer((_) async => Right(tPaginatedProducts()));
      },
      build: buildCubit,
      act: (cubit) => cubit.selectCategory('beauty'),
      expect: () => [
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          categories: const [tProductCategory],
          hasMore: false,
          selectedCategory: 'beauty',
          isSwitchingCategory: true,
        ),
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          categories: const [tProductCategory],
          hasMore: false,
          selectedCategory: 'beauty',
          isSwitchingCategory: false,
        ),
      ],
      verify: (_) {
        verify(() => getProductsByCategory(const GetProductsByCategoryParams(category: 'beauty', skip: 0)))
            .called(1);
      },
    );

    blocTest<CatalogCubit, CatalogState>(
      'seleccionar la misma categoría otra vez la deselecciona (vuelve a "Todo")',
      seed: () => CatalogState(
        status: CatalogStatus.loaded,
        products: const [tProduct],
        selectedCategory: 'beauty',
        hasMore: false,
      ),
      setUp: () {
        when(() => getProducts(any())).thenAnswer((_) async => Right(tPaginatedProducts()));
      },
      build: buildCubit,
      act: (cubit) => cubit.selectCategory('beauty'),
      expect: () => [
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          hasMore: false,
          isSwitchingCategory: true,
        ),
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          hasMore: false,
          isSwitchingCategory: false,
        ),
      ],
      verify: (_) {
        verify(() => getProducts(const GetProductsParams(skip: 0))).called(1);
        verifyZeroInteractions(getProductsByCategory);
      },
    );

    blocTest<CatalogCubit, CatalogState>(
      'si el filtrado falla, restaura la selección y los productos previos',
      seed: () => CatalogState(
        status: CatalogStatus.loaded,
        products: const [tProduct],
        hasMore: false,
      ),
      setUp: () {
        when(() => getProductsByCategory(any())).thenAnswer((_) async => const Left(ServerFailure()));
      },
      build: buildCubit,
      act: (cubit) => cubit.selectCategory('beauty'),
      expect: () => [
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          hasMore: false,
          selectedCategory: 'beauty',
          isSwitchingCategory: true,
        ),
        CatalogState(
          status: CatalogStatus.loaded,
          products: const [tProduct],
          hasMore: false,
          isSwitchingCategory: false,
        ),
      ],
    );
  });
}

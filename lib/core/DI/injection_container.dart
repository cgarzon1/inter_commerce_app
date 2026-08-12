import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../persistence/objectbox_store.dart';
import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/add_cart_item.dart';
import '../../features/cart/domain/usecases/apply_promo_code.dart';
import '../../features/cart/domain/usecases/calculate_cart_totals.dart';
import '../../features/cart/domain/usecases/get_cart.dart';
import '../../features/cart/domain/usecases/remove_cart_item.dart';
import '../../features/cart/domain/usecases/remove_promo_code.dart';
import '../../features/cart/domain/usecases/update_cart_item_quantity.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/products/data/datasources/product_local_data_source.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_product_categories.dart';
import '../../features/products/domain/usecases/get_product_detail.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/get_products_by_category.dart';
import '../../features/products/domain/usecases/search_products.dart';
import '../../features/products/presentation/cubit/catalog_cubit.dart';
import '../../features/products/presentation/cubit/product_detail_cubit.dart';
import '../../features/products/presentation/cubit/search_cubit.dart';


final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initExternal();
  _initCore();
  _initProductsFeature();
  _initCartFeature();
}

/// Third-party clients that don't belong to any single feature.
Future<void> _initExternal() async {
  sl.registerLazySingleton<Dio>(() => DioClient.create());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  final objectBoxStore = await ObjectBoxStore.create();
  sl.registerSingleton<ObjectBoxStore>(objectBoxStore);
}

/// Cross-cutting infrastructure every feature can depend on.
void _initCore() {
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}

void _initProductsFeature() {
  // Domain — Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => GetProductDetail(sl()));
  sl.registerLazySingleton(() => GetProductCategories(sl()));
  sl.registerLazySingleton(() => GetProductsByCategory(sl()));

  // Data — Repository (registered against the Domain interface)
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data 
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sl()),
  );

  sl.registerFactory(() => CatalogCubit(
        getProducts: sl(),
        getProductsByCategory: sl(),
        getCategories: sl(),
      ));
  sl.registerFactory(() => ProductDetailCubit(getProductDetail: sl()));
  sl.registerFactory(() => SearchCubit(searchProducts: sl()));
}

void _initCartFeature() {
  // Domain — Use cases
  sl.registerLazySingleton(() => GetCart(sl()));
  sl.registerLazySingleton(() => AddCartItem(sl()));
  sl.registerLazySingleton(() => UpdateCartItemQuantity(sl()));
  sl.registerLazySingleton(() => RemoveCartItem(sl()));
  sl.registerLazySingleton(() => ApplyPromoCode(sl()));
  sl.registerLazySingleton(() => RemovePromoCode(sl()));
  sl.registerLazySingleton(() => const CalculateCartTotals());

  // Data — Repository (registered against the Domain interface)
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: sl()),
  );

  // Data — Datasource (ObjectBox)
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sl()),
  );

  // Presentation 
  sl.registerLazySingleton(() => CartCubit(
        getCart: sl(),
        addCartItem: sl(),
        updateCartItemQuantity: sl(),
        removeCartItem: sl(),
        applyPromoCode: sl(),
        removePromoCode: sl(),
        calculateCartTotals: sl(),
      ));
}

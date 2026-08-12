import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_product_detail.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/search_products.dart';

/// App-wide Service Locator. `main.dart` calls [initDependencies] once,
/// before `runApp`, and every layer resolves what it needs from [sl] —
/// with one exception: `sl` is only ever read from a composition root
/// (a page's `BlocProvider(create: ...)`), never from inside a widget's
/// build method.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  _initExternal();
  _initCore();
  _initProductsFeature();
}

/// Third-party clients that don't belong to any single feature.
void _initExternal() {
  sl.registerLazySingleton<Dio>(() => DioClient.create());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
}

/// Cross-cutting infrastructure every feature can depend on.
void _initCore() {
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}

/// Registration block for the `products` feature. New features get their
/// own private `_initXxxFeature()` function following this exact shape:
/// use cases first (lazy singletons — stateless), then repository (lazy
/// singleton, bound to its interface), then datasource(s) last.
void _initProductsFeature() {
  // Domain — Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => GetProductDetail(sl()));

  // Data — Repository (registered against the Domain interface)
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data — Datasource
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );

  // Presentation — Cubit/Bloc goes here as `registerFactory(...)` once the
  // UI layer is implemented (a fresh instance per screen, never a
  // singleton).
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
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
      networkInfo: sl(),
    ),
  );

  // Data — Datasource
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );

  sl.registerFactory(() => CatalogCubit(
        getProducts: sl(),
        getProductsByCategory: sl(),
        getCategories: sl(),
      ));
  sl.registerFactory(() => ProductDetailCubit(getProductDetail: sl()));
}

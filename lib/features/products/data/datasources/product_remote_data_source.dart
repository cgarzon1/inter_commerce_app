import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/paginated_products_model.dart';
import '../models/product_category_model.dart';
import '../models/product_model.dart';


abstract class ProductRemoteDataSource {
  Future<PaginatedProductsModel> getProducts({
    required int limit,
    required int skip,
  });

  Future<PaginatedProductsModel> searchProducts({
    required String query,
    required int limit,
    required int skip,
  });

  Future<PaginatedProductsModel> getProductsByCategory({
    required String category,
    required int limit,
    required int skip,
  });

  Future<ProductModel> getProductById(int id);

  Future<List<ProductCategoryModel>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  const ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<PaginatedProductsModel> getProducts({
    required int limit,
    required int skip,
  }) async {
    final response = await _get(
      ApiConstants.products,
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return PaginatedProductsModel.fromJson(response);
  }

  @override
  Future<PaginatedProductsModel> searchProducts({
    required String query,
    required int limit,
    required int skip,
  }) async {
    final response = await _get(
      ApiConstants.productsSearch,
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );
    return PaginatedProductsModel.fromJson(response);
  }

  @override
  Future<PaginatedProductsModel> getProductsByCategory({
    required String category,
    required int limit,
    required int skip,
  }) async {
    final response = await _get(
      ApiConstants.productsByCategory(category),
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return PaginatedProductsModel.fromJson(response);
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await _get(ApiConstants.productDetail(id));
    return ProductModel.fromJson(response);
  }

  @override
  Future<List<ProductCategoryModel>> getCategories() async {
    final response = await _getList(ApiConstants.productCategories);
    return response
        .map((e) => ProductCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );

      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw ServerException(
          message: 'Respuesta inválida del servidor',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Same as [_get], for the one DummyJSON endpoint in scope that
  /// returns a bare JSON array instead of an object (`/products/categories`).
  Future<List<dynamic>> _getList(String path) async {
    try {
      final response = await dio.get<List<dynamic>>(path);

      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw ServerException(
          message: 'Respuesta inválida del servidor',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error de red',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

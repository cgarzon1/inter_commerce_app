import 'package:inter_commerce_app/features/products/domain/entities/paginated_products.dart';
import 'package:inter_commerce_app/features/products/domain/entities/product.dart';
import 'package:inter_commerce_app/features/products/domain/entities/product_category.dart';

/// Shared fixtures for `products` domain/presentation tests — kept in one
/// place so every test file builds the same shape of [Product].
const tProduct = Product(
  id: 1,
  title: 'Essence Mascara Lash Princess',
  description: 'The Essence Mascara Lash Princess is a popular mascara.',
  category: 'beauty',
  price: 9.99,
  discountPercentage: 7.17,
  rating: 4.94,
  stock: 5,
  tags: ['beauty', 'mascara'],
  brand: 'Essence',
  sku: 'BEA-ESS-ESS-001',
  availabilityStatus: 'Low Stock',
  thumbnail: 'https://cdn.dummyjson.com/products/images/beauty/1/thumbnail.webp',
  images: ['https://cdn.dummyjson.com/products/images/beauty/1/1.webp'],
);

const tProductCategory = ProductCategory(slug: 'beauty', name: 'Beauty');

PaginatedProducts tPaginatedProducts({bool isFromCache = false}) => PaginatedProducts(
      products: const [tProduct],
      total: 1,
      skip: 0,
      limit: 20,
      isFromCache: isFromCache,
    );

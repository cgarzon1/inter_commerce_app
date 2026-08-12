import 'package:equatable/equatable.dart';


class CartItem extends Equatable {
  final int productId;
  final String title;

  final String subtitle;
  final String thumbnail;
  final double unitPrice;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.title,
    required this.subtitle,
    required this.thumbnail,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      title: title,
      subtitle: subtitle,
      thumbnail: thumbnail,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [productId, title, subtitle, thumbnail, unitPrice, quantity];
}

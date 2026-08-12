import 'package:equatable/equatable.dart';

import 'cart_item.dart';
import 'cart_promo.dart';


class Cart extends Equatable {
  final List<CartItem> items;
  final CartPromo? promo;

  const Cart({this.items = const [], this.promo});

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  @override
  List<Object?> get props => [items, promo];
}

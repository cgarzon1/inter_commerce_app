import 'package:equatable/equatable.dart';


class CartTotals extends Equatable {
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double shippingAmount;
  final double total;

  const CartTotals({
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.discountAmount,
    required this.shippingAmount,
    required this.total,
  });

  @override
  List<Object?> get props => [subtotal, taxRate, taxAmount, discountAmount, shippingAmount, total];
}

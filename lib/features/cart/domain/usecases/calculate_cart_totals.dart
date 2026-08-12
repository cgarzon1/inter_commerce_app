import 'package:fpdart/fpdart.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/cart.dart';
import '../entities/cart_totals.dart';


///   1. `discount = subtotal × promo.discountPercentage`
///   2. `taxable = subtotal − discount` (tax applies *after* discount)
///   3. `tax = taxable × taxRate`
///   4. `total = taxable + tax + shipping`
class CalculateCartTotals implements UseCase<CartTotals, Cart> {
  const CalculateCartTotals();

  static const double taxRate = 0.16;
  static const double shippingAmount = 0;

  @override
  ResultFuture<CartTotals> call(Cart cart) {
    final subtotal = cart.subtotal;
    final discountAmount = subtotal * (cart.promo?.discountPercentage ?? 0) / 100;
    final taxableAmount = subtotal - discountAmount;
    final taxAmount = taxableAmount * taxRate;
    final total = taxableAmount + taxAmount + shippingAmount;

    return Future.value(Right(CartTotals(
      subtotal: subtotal,
      taxRate: taxRate,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      shippingAmount: shippingAmount,
      total: total,
    )));
  }
}

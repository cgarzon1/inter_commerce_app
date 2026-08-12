import 'package:equatable/equatable.dart';

class CartPromo extends Equatable {
  final String code;
  final double discountPercentage;

  const CartPromo({required this.code, required this.discountPercentage});

  @override
  List<Object?> get props => [code, discountPercentage];
}

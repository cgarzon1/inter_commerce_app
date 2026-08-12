import 'package:flutter/material.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';


class PromoCodeField extends StatefulWidget {
  const PromoCodeField({
    super.key,
    required this.hintText,
    required this.applyLabel,
    required this.errorText,
    required this.onApply,
  });

  final String hintText;
  final String applyLabel;
  final String? errorText;
  final ValueChanged<String> onApply;

  @override
  State<PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<PromoCodeField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    widget.onApply(code);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InterCommerceTextField(
            controller: _controller,
            hintText: widget.hintText,
            errorText: widget.errorText,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: InterCommerceSpacing.sm),
        InterCommerceButton(
          label: widget.applyLabel,
          expand: false,
          height: InterCommerceControlSize.textField,
          onPressed: _submit,
        ),
      ],
    );
  }
}

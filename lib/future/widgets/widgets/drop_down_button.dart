import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/models/models/typedef.dart'
    show FuncVoidNullT, NullStringT;

class AppDropDownBottom<T> extends StatelessWidget {
  const AppDropDownBottom(
      {super.key,
      this.items,
      this.menuItems,
      this.label,
      this.selectedItemBuilder,
      this.value,
      this.onChanged,
      this.validator,
      this.icon,
      this.error,
      this.contentPadding,
      this.isExpanded = false,
      this.focusColor,
      this.fillColor,
      this.helperText,
      this.labelStyle,
      this.border,
      this.iconEnabledColor,
      this.hint});
  final Map<T, Widget>? items;
  final List<DropdownMenuItem<T>>? menuItems;
  final Map<T, Widget>? selectedItemBuilder;
  final FuncVoidNullT<T?>? onChanged;
  final NullStringT<T>? validator;
  final String? label;
  final Widget? icon;
  final String? error;
  final T? value;
  final bool isExpanded;
  final Color? focusColor;
  final Color? fillColor;
  final String? helperText;
  final TextStyle? labelStyle;
  final InputBorder? border;
  final Color? iconEnabledColor;
  final String? hint;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final currentItems = menuItems ??
        items?.keys
            .map<DropdownMenuItem<T>>(
                (e) => DropdownMenuItem<T>(value: e, child: items![e]!))
            .toList() ??
        [];
    return DropdownButtonFormField<T>(
      items: selectedItemBuilder?.keys
              .map<DropdownMenuItem<T>>((e) => DropdownMenuItem<T>(
                  value: e, child: selectedItemBuilder![e]!))
              .toList() ??
          currentItems,
      icon: icon,
      selectedItemBuilder: (context) => currentItems,
      onChanged: onChanged,
      validator: validator,
      isExpanded: isExpanded,

      value: value,
      focusColor: focusColor,

      iconEnabledColor: iconEnabledColor,

      hint: hint == null ? null : Text(hint!),
      // focusColor: context.colors.transparent,
      decoration: InputDecoration(
          focusColor: focusColor,
          labelText: label,
          errorText: error,
          fillColor: fillColor,
          errorMaxLines: 3,
          helperText: helperText,
          contentPadding: contentPadding,
          alignLabelWithHint: true,
          border: InputBorder.none,
          helperMaxLines: 3),
    );
  }
}

import 'package:flutter/material.dart';

class KeyboardAwareLayout extends StatelessWidget {
  final Widget child;
  final double bottomPadding;

  const KeyboardAwareLayout({
    super.key,
    required this.child,
    this.bottomPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + bottomPadding,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.primaryColor,
        ),
      ),
    );
  }
}
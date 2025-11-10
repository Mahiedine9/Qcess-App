import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color? color;
  final String? message;
  final double? size;

  const LoadingWidget({
    this.color,
    this.message,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Colors.white,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InlineLoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const InlineLoadingWidget({
    this.color,
    this.size = 24,
    this.strokeWidth = 2.5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final String? message;
  final bool overlay;

  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color = Colors.blue,
    this.message,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget loadingWidget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16.0),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: overlay ? Colors.white : Colors.black87,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]
        ],
      ),
    );

    if (overlay) {
      return Container(
        color: Colors.black.withOpacity(0.7),
        child: loadingWidget,
      );
    }

    return loadingWidget;
  }
}

class OverlayLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;

  const OverlayLoadingIndicator({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: LoadingIndicator(
              overlay: true,
              message: loadingMessage,
            ),
          ),
      ],
    );
  }
}

// Simple loading button
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height = 48.0,
    this.borderRadius = 10.0,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue[900],
          foregroundColor: textColor ?? Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
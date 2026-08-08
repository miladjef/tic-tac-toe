import 'package:flutter/material.dart';

class InnerShadowContainer extends StatelessWidget {
  final Widget? child;
  final double? dropShadowBlurRadius;
  final Offset? dropShadowOffset;
  final Offset? translateOffset;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BoxShape shape;

  const InnerShadowContainer({
    super.key,
    this.child,
    this.dropShadowBlurRadius,
    this.translateOffset,
    this.dropShadowOffset,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.backgroundColor, // Default background color
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: translateOffset ?? Offset.zero,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor, // Set background color
          borderRadius:
              shape == BoxShape.rectangle ? BorderRadius.circular(8) : null,
          shape: shape,
          border:
              Border.all(color: const Color(0xff515151).withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffFFFFFF).withValues(alpha: 0.07),
            ),
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
              offset: const Offset(5, 5),
              spreadRadius: 0,
              blurRadius: 0,
            ),
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.23),
              blurRadius: dropShadowBlurRadius ?? 8,
              spreadRadius: 0,
              offset: dropShadowOffset ?? const Offset(3, 3),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// class InnerShadowContainer extends StatelessWidget {
//   final Widget? child;
//   final double? dropShadowBlurRadius;
//   final Offset? dropShadowOffset;
//   final Offset? translateOffset;
//   final double? width;
//   final double? height;
//   final Color? backgroundColor;

//   const InnerShadowContainer({
//     super.key,
//     this.child,
//     this.dropShadowBlurRadius,
//     this.translateOffset,
//     this.dropShadowOffset,
//     this.width,
//     this.height,
//     this.backgroundColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Transform.translate(
//       offset: translateOffset ?? Offset.zero,
//       child: Container(
//         width: width,
//         height: height,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: backgroundColor ?? AppColors.white, // Default background color
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.black.withOpacity(0.1), // Subtle outer shadow
//               blurRadius: dropShadowBlurRadius ?? 8,
//               offset: dropShadowOffset ?? const Offset(3, 3),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             // Custom painter for inner shadow
//             CustomPaint(
//               size: Size(width ?? 100, height ?? 100),
//               painter: InnerShadowPainter(
//                 borderRadius: 8,
//                 shadowColor: AppColors.black.withOpacity(0.2),
//                 blurRadius: dropShadowBlurRadius ?? 8,
//                 shadowOffset: dropShadowOffset ?? const Offset(3, 3),
//               ),
//             ),
//             // Child widget
//             if (child != null) Center(child: child),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class InnerShadowContainer extends StatelessWidget {
//   final Widget? child;
//   final double? dropShadowBlurRadius;
//   final Offset? dropShadowOffset;
//   final Offset? translateOffset;
//   final double? width;
//   final double? height;
//   final Color? backgroundColor;

//   const InnerShadowContainer({
//     super.key,
//     this.child,
//     this.dropShadowBlurRadius,
//     this.translateOffset,
//     this.dropShadowOffset,
//     this.width,
//     this.height,
//     this.backgroundColor, // Default background color
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Transform.translate(
//       offset: translateOffset ?? Offset.zero,
//       child: Container(
//         width: width,
//         height: height,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: backgroundColor ??
//               context.color.surface.withAlpha(), // Default background color
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: const Color(0xff515151).withOpacity(0.9),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xffFFFFFF).withOpacity(0.07),
//             ),
//             BoxShadow(
//               color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
//               offset: const Offset(5, 5),
//               spreadRadius: 0,
//               blurRadius: 0,
//             ),
//             BoxShadow(
//               color: Theme.of(context).colorScheme.surface.withOpacity(0.23),
//               blurRadius: dropShadowBlurRadius ?? 8,
//               spreadRadius: 0,
//               offset: dropShadowOffset ?? const Offset(3, 3),
//             ),
//           ],
//         ),
//         child: child,
//       ),
//     );
//   }
// }

// class InnerShadowPainter extends CustomPainter {
//   final double borderRadius;
//   final Color shadowColor;
//   final double blurRadius;
//   final Offset shadowOffset;

//   InnerShadowPainter({
//     required this.borderRadius,
//     required this.shadowColor,
//     required this.blurRadius,
//     required this.shadowOffset,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height);
//     final paint = Paint()
//       ..color = shadowColor
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

//     final path = Path()
//       ..addRRect(
//         RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
//       )
//       ..addRRect(
//         RRect.fromRectAndRadius(
//           rect.shift(shadowOffset),
//           Radius.circular(borderRadius),
//         ),
//       )
//       ..fillType = PathFillType.evenOdd;

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

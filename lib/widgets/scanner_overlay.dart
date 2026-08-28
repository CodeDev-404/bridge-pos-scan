import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Corner decorations
              Positioned(
                top: -1,
                left: -1,
                child: _buildCorner(Colors.green, top: true, left: true),
              ),
              Positioned(
                top: -1,
                right: -1,
                child: _buildCorner(Colors.green, top: true, right: true),
              ),
              Positioned(
                bottom: -1,
                left: -1,
                child: _buildCorner(Colors.green, bottom: true, left: true),
              ),
              Positioned(
                bottom: -1,
                right: -1,
                child: _buildCorner(Colors.green, bottom: true, right: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(Color color,
      {bool top = false, bool bottom = false, bool left = false, bool right = false}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: color, width: 3) : BorderSide.none,
          bottom: bottom ? BorderSide(color: color, width: 3) : BorderSide.none,
          left: left ? BorderSide(color: color, width: 3) : BorderSide.none,
          right: right ? BorderSide(color: color, width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    // Draw dimmed area around scan region
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(scanArea)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw scan line animation placeholder
    final linePaint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(scanArea.left + 10, scanArea.center.dy),
      Offset(scanArea.right - 10, scanArea.center.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

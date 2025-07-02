import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'huffman_class.dart';

class HuffmanTreePainter extends CustomPainter {
  final HuffmanNode root;
  final double animationValue;

  HuffmanTreePainter(this.root, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Map<HuffmanNode, double> xPositions = {};
    int totalPositions = _calculateXPositions(root, xPositions);
    double nodeSpacing = 60.0.w;
    double totalWidth = totalPositions * nodeSpacing;
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    xPositions.values.forEach((x) {
      minX = min(minX, x);
      maxX = max(maxX, x);
    });
    double xScale =
        (maxX - minX + 1) > 0 ? totalWidth / (maxX - minX + 1) : 1.0;
    double xOffset = (size.width - totalWidth) / 2 - minX * xScale;
    if (xOffset.isNaN || xOffset.isInfinite) xOffset = 0.0;
    int depth = _maxDepth(root);
    double topPad = 40.h, bottomPad = 40.h;
    double availH = size.height - topPad - bottomPad;
    double vStep = depth > 1 ? availH / (depth - 1) : availH;

    final edgePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    final nodePaint =
        Paint()
          ..color = Colors.blue.shade700
          ..style = PaintingStyle.fill;
    final leafPaint =
        Paint()
          ..color = Colors.green.shade600
          ..style = PaintingStyle.fill;
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
    );

    void drawNode(HuffmanNode? node, int nodeDepth, double progress) {
      if (node == null || progress < nodeDepth * 0.1) return;
      final double x = xPositions[node]! * xScale + xOffset;
      final double y = topPad + nodeDepth * vStep;
      final Offset pos = Offset(x, y);
      final isLeaf = node.left == null && node.right == null;
      canvas.drawCircle(pos, 20.r, isLeaf ? leafPaint : nodePaint);
      String nodeText =
          isLeaf && node.pixelValue != null
              ? "${node.pixelValue}"
              : node.frequency.toString();
      final tp = TextPainter(
        text: TextSpan(text: nodeText, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));

      if (node.left != null) {
        final leftX = xPositions[node.left]! * xScale + xOffset;
        final leftY = topPad + (nodeDepth + 1) * vStep;
        final leftPos = Offset(leftX, leftY);
        canvas.drawLine(pos, leftPos, edgePaint);
        final labelPos = Offset.lerp(pos, leftPos, 0.4)!;
        TextPainter(
            text:   TextSpan(
              text: '0',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
            textDirection: TextDirection.ltr,
          )
          ..layout()
          ..paint(canvas, labelPos - Offset(8.w, 8.h));
        drawNode(node.left, nodeDepth + 1, progress);
      }

      if (node.right != null) {
        final rightX = xPositions[node.right]! * xScale + xOffset;
        final rightY = topPad + (nodeDepth + 1) * vStep;
        final rightPos = Offset(rightX, rightY);
        canvas.drawLine(pos, rightPos, edgePaint);
        final labelPos = Offset.lerp(pos, rightPos, 0.4)!;
        TextPainter(
            text:   TextSpan(
              text: '1',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
            textDirection: TextDirection.ltr,
          )
          ..layout()
          ..paint(canvas, labelPos - Offset(0, 12.h));
        drawNode(node.right, nodeDepth + 1, progress);
      }
    }

    drawNode(root, 0, animationValue);
  }

  int _calculateXPositions(
    HuffmanNode? node,
    Map<HuffmanNode, double> positions, [
    int pos = 0,
  ]) {
    if (node == null) return pos;
    if (node.left == null && node.right == null) {
      positions[node] = pos.toDouble();
      return pos + 2;
    }
    int rightPos = _calculateXPositions(node.left, positions, pos);
    int nextPos = _calculateXPositions(node.right, positions, rightPos);
    if (node.left != null && node.right != null) {
      positions[node] = (positions[node.left]! + positions[node.right]!) / 2;
    } else if (node.left != null) {
      positions[node] = positions[node.left]!;
    } else if (node.right != null) {
      positions[node] = positions[node.right]!;
    } else {
      positions[node] = pos.toDouble();
    }
    return nextPos;
  }

  int _maxDepth(HuffmanNode? node) {
    if (node == null) return 0;
    return 1 + max(_maxDepth(node.left), _maxDepth(node.right));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

import 'huffman_class.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TreeWidthCalculator {
  static double calculateTreeWidth(HuffmanNode root, double nodeSpacing) {
    Map<HuffmanNode, double> xPositions = {};
    int totalPositions = _calculateXPositions(root, xPositions);
    return totalPositions * nodeSpacing.w;
  }

  static int _calculateXPositions(
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
}

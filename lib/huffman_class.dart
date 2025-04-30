class HuffmanNode {
  int? pixelValue;
  int frequency;
  HuffmanNode? left;
  HuffmanNode? right;
  bool isHighlighted = false;

  HuffmanNode(this.pixelValue, this.frequency, [this.left, this.right]);

  @override
  String toString() {
    return pixelValue != null
        ? 'Value: $pixelValue, Freq: $frequency'
        : 'Internal: $frequency';
  }

  String getCode() {
    return pixelValue != null ? '$pixelValue' : '★';
  }
}

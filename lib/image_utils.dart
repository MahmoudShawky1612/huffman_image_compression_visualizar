import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'huffman_class.dart';

Future<img.Image?> decodeImage(File file) async {
  try {
    return img.decodeImage(file.readAsBytesSync());
  } catch (e) {
    print('Error decoding image: $e');
    return null;
  }
}

Future<File?> convertToGrayscale(File original) async {
  try {
    final image = await decodeImage(original);
    if (image == null) return null;

    img.Image grayscale = img.grayscale(image);
    final directory = await getTemporaryDirectory();
    String path =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_grayscale.png';
    File grayscaleFile = File(path)..writeAsBytesSync(img.encodePng(grayscale));
    return grayscaleFile;
  } catch (e) {
    print('Error converting to grayscale: $e');
    return null;
  }
}

Map<int, int> calculateHistogram(img.Image image) {
  Map<int, int> histogram = {};
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y).r.toInt();
      histogram[pixel] = (histogram[pixel] ?? 0) + 1;
    }
  }
  return histogram;
}

Map<int, String> generateHuffmanCodes(HuffmanNode root) {
  Map<int, String> codes = {};
  void traverse(HuffmanNode? node, String code) {
    if (node == null) return;
    if (node.pixelValue != null) {
      codes[node.pixelValue!] = code.isEmpty ? '0' : code;
    }
    traverse(node.left, code + '0');
    traverse(node.right, code + '1');
  }

  traverse(root, '');
  return codes;
}

String compressImage(img.Image image, Map<int, String> huffmanCodes) {
  StringBuffer bitstream = StringBuffer();
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y).r.toInt();
      String code = huffmanCodes[pixel]!;
      bitstream.write(code);
    }
  }
  return bitstream.toString();
}

List<int> decompressBitstream(String bitstream, HuffmanNode root) {
  List<int> pixels = [];
  HuffmanNode current = root;
  for (int i = 0; i < bitstream.length; i++) {
    String bit = bitstream[i];
    if (bit == '0') {
      current = current.left!;
    } else {
      current = current.right!;
    }
    if (current.left == null && current.right == null) {
      pixels.add(current.pixelValue!);
      current = root;
    }
  }
  return pixels;
}

double calculateCompressionRatio(img.Image image, String bitstream) {
  int originalSizeBits = image.width * image.height * 8;
  int compressedSizeBits = bitstream.length;
  if (compressedSizeBits == 0) return 0.0;
  return originalSizeBits / compressedSizeBits;
}

Uint8List bitstreamToBytes(String bits) {
  final byteCount = (bits.length + 7) ~/ 8;
  final out = Uint8List(byteCount);
  for (int i = 0; i < bits.length; i++) {
    if (bits[i] == '1') {
      out[i ~/ 8] |= (1 << (7 - (i % 8)));
    }
  }
  return out;
}

Uint8List serializeHuffmanCodes(Map<int, String> huffmanCodes) {
  List<int> buffer = [];
  // Write number of Huffman codes (2 bytes)
  buffer.addAll(
    Uint8List(2)..buffer.asByteData().setUint16(0, huffmanCodes.length),
  );
  // Write each code: pixel value (1 byte), code length (1 byte), code bits
  huffmanCodes.forEach((pixelValue, code) {
    buffer.add(pixelValue & 0xFF); // Pixel value (1 byte)
    buffer.add(code.length & 0xFF); // Code length (1 byte)
    // Convert code string to bytes
    int byteCount = (code.length + 7) ~/ 8;
    Uint8List codeBytes = Uint8List(byteCount);
    for (int i = 0; i < code.length; i++) {
      if (code[i] == '1') {
        codeBytes[i ~/ 8] |= (1 << (7 - (i % 8)));
      }
    }
    buffer.addAll(codeBytes);
  });
  return Uint8List.fromList(buffer);
}

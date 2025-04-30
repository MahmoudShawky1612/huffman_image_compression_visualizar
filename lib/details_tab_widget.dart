import 'package:flutter/material.dart';

class DetailsTabWidget extends StatelessWidget {
  final Size screenSize;
  final Map<int, String>? huffmanCodes;

  const DetailsTabWidget({
    super.key,
    required this.screenSize,
    required this.huffmanCodes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child:
          huffmanCodes == null
              ? _buildPlaceholder(
                'Select an image to see compression details',
                screenSize,
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Huffman Codes',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Expanded(
                    child: Card(
                      elevation: 8,
                      color: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          screenSize.width * 0.04,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenSize.width * 0.04),
                        child: _buildHuffmanCodesTable(screenSize),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildHuffmanCodesTable(Size screenSize) {
    if (huffmanCodes == null) return const SizedBox();
    List<int> sortedKeys = huffmanCodes!.keys.toList()..sort();
    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        int pixelValue = sortedKeys[index];
        String code = huffmanCodes![pixelValue]!;
        return ListTile(
          title: Row(
            children: [
              Flexible(
                child: Text(
                  'Pixel $pixelValue',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.02,
                    vertical: screenSize.height * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade700,
                    borderRadius: BorderRadius.circular(
                      screenSize.width * 0.04,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Text(
                      code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenSize.width * 0.02),
              Text(
                '(${code.length} bits)',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(String message, Size screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_search,
            size: screenSize.width * 0.15,
            color: Colors.deepPurple.shade200,
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            message,
            style: TextStyle(
              color: Colors.deepPurple.shade200,
              fontSize: screenSize.width * 0.04,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

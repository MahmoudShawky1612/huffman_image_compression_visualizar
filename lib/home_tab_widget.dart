import 'dart:io';

import 'package:flutter/material.dart';

class HomeTabWidget extends StatelessWidget {
  final Size screenSize;
  final File? originalImage;
  final File? grayscaleImage;
  final double? compressionRatio;

  const HomeTabWidget({
    super.key,
    required this.screenSize,
    required this.originalImage,
    required this.grayscaleImage,
    required this.compressionRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image Preview',
            style: TextStyle(
              fontSize: screenSize.width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          Expanded(
            child: Center(
              child:
                  originalImage == null
                      ? _buildPlaceholder(
                        'Select an image to begin',
                        screenSize,
                      )
                      : _buildImagePreview(screenSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(Size screenSize) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenSize.width * 0.04),
      ),
      color: Colors.black12,
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageSize = constraints.maxWidth * 0.4;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (originalImage != null)
                    _buildImageCard(
                      'Original',
                      originalImage!,
                      Colors.blue.shade900,
                      originalImage.hashCode.toString(),
                      imageSize,
                    ),
                  SizedBox(width: screenSize.width * 0.04),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.deepPurple.shade200,
                        size: screenSize.width * 0.08,
                      ),
                      SizedBox(height: screenSize.height * 0.01),
                      if (compressionRatio != null)
                        Text(
                          '${compressionRatio!.toStringAsFixed(2)}x smaller',
                          style: TextStyle(
                            color: Colors.deepPurple.shade200,
                            fontWeight: FontWeight.bold,
                            fontSize: screenSize.width * 0.035,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: screenSize.width * 0.04),
                  if (grayscaleImage != null)
                    _buildImageCard(
                      'Grayscale (.hff output)',
                      grayscaleImage!,
                      Colors.green.shade900,
                      grayscaleImage.hashCode.toString(),
                      imageSize,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageCard(
    String label,
    File image,
    Color color,
    String key,
    double imageSize,
  ) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.file(image, fit: BoxFit.cover, key: ValueKey(key)),
          ),
        ),
        SizedBox(height: imageSize * 0.05),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: imageSize * 0.08,
            vertical: imageSize * 0.03,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(imageSize * 0.08),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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

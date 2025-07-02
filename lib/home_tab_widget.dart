import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.all(14.4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image Preview',
            style: TextStyle(
              fontSize: 16.2.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 13.8.h),
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
        borderRadius: BorderRadius.circular(14.4.w),
      ),
      color: Colors.black12,
      child: Padding(
        padding: EdgeInsets.all(14.4.w),
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
                  SizedBox(width: 14.4.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.deepPurple.shade200,
                        size: 28.8.w,
                      ),
                      SizedBox(height: 6.9.h),
                      if (compressionRatio != null)
                        Text(
                          '${compressionRatio!.toStringAsFixed(2)}x smaller',
                          style: TextStyle(
                            color: Colors.deepPurple.shade200,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.6.sp,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 14.4.w),
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
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2.w),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Image.file(image, fit: BoxFit.cover, key: ValueKey(key)),
          ),
        ),
        SizedBox(height: (imageSize * 0.05).h),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: (imageSize * 0.08).w,
            vertical: (imageSize * 0.03).h,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular((imageSize * 0.08).r),
          ),
          child: Text(
            label,
            style:   TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.4.sp,
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
            size: 54.w,
            color: Colors.deepPurple.shade200,
          ),
          SizedBox(height: 13.8.h),
          Text(
            message,
            style: TextStyle(
              color: Colors.deepPurple.shade200,
              fontSize: 14.4.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.all(14.4.w),
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
                      fontSize: 16.2.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 13.8.h),
                  Expanded(
                    child: Card(
                      elevation: 8,
                      color: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          14.4.w,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.4.w),
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
                    horizontal: 7.2.w,
                    vertical: 3.45.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade700,
                    borderRadius: BorderRadius.circular(
                      14.4.w,
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
              SizedBox(width: 7.2.w),
              Text(
                '(${code.length} bits)',
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
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

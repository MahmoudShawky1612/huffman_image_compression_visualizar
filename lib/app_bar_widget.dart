import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final Size screenSize;
  final TabController tabController;
  final bool isLoading;
  final VoidCallback onPickImage;

  const AppBarWidget({
    super.key,
    required this.screenSize,
    required this.tabController,
    required this.isLoading,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.02,
        horizontal: screenSize.width * 0.02,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.compress, size: screenSize.width * 0.08),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Huffman Image Compressor',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onPickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.04,
                        vertical: screenSize.height * 0.01,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02),
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.account_tree), text: 'Visualization'),
              Tab(icon: Icon(Icons.data_object), text: 'Details'),
            ],
            labelColor: Colors.white,
            indicatorColor: Colors.deepPurple.shade200,
          ),
        ],
      ),
    );
  }
}

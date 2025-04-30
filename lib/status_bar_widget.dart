import 'package:flutter/material.dart';

class StatusBarWidget extends StatelessWidget {
  final Size screenSize;
  final bool isLoading;
  final String statusMessage;
  final double? compressionRatio;

  const StatusBarWidget({
    super.key,
    required this.screenSize,
    required this.isLoading,
    required this.statusMessage,
    required this.compressionRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.01,
        horizontal: screenSize.width * 0.04,
      ),
      color: Colors.black26,
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: screenSize.width * 0.04,
              height: screenSize.width * 0.04,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.deepPurple.shade200,
              ),
            ),
          if (isLoading) SizedBox(width: screenSize.width * 0.03),
          Expanded(
            child: Text(
              statusMessage,
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (compressionRatio != null)
            Text(
              'Ratio: ${compressionRatio!.toStringAsFixed(2)}x',
              style: TextStyle(
                color: Colors.greenAccent.shade200,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

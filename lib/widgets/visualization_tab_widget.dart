import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import '../huffman/huffman_class.dart';
import '../huffman/huffman_tree_painter.dart';
import '../huffman/tree_width_calculator.dart';

class VisualizationTabWidget extends StatelessWidget {
  final Size screenSize;
  final List<List<HuffmanNode>> compressionSteps;
  final int currentStep;
  final bool isAnimating;
  final double stepDuration;
  final Animation<double> animation;
  final VoidCallback onPreviousStep;
  final VoidCallback onNextStep;
  final VoidCallback onToggleAnimation;
  final ValueChanged<double> onStepDurationChanged;

  VisualizationTabWidget({
    super.key,
    required this.screenSize,
    required this.compressionSteps,
    required this.currentStep,
    required this.isAnimating,
    required this.stepDuration,
    required this.animation,
    required this.onPreviousStep,
    required this.onNextStep,
    required this.onToggleAnimation,
    required this.onStepDurationChanged,
  });

  final GlobalKey _treeBoundaryKey = GlobalKey();

  Future<void> _downloadTree(
    BuildContext context,
    HuffmanNode root,
    Size screenSize,
  ) async {
    // Show dialog to choose format
    final format = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Download Format'),
            content: const Text('Select the format to save the Huffman tree.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'pdf'),
                child: const Text('PDF'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'png'),
                child: const Text('PNG'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );

    if (format == null) return;

    // Request storage permissions
    var status = await Permission.manageExternalStorage.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    try {
      // Calculate tree dimensions
      double nodeSpacing = 60.0.w;
      double horizontalMargin = 40.0.w;
      double treeWidth = TreeWidthCalculator.calculateTreeWidth(
        root,
        nodeSpacing,
      );
      double totalWidth = max(
        treeWidth + horizontalMargin * 2,
        screenSize.width,
      );
      double treeHeight = screenSize.height * 1.5;

      // Render the entire tree
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, totalWidth, treeHeight),
      );
      final painter = HuffmanTreePainter(root, 1.0); // Full animation value
      painter.paint(canvas, Size(totalWidth, treeHeight));
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        totalWidth.toInt(),
        treeHeight.toInt(),
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (format == 'pdf') {
        final pdf = pw.Document();
        final pwImage = pw.MemoryImage(pngBytes);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context ctx) {
              final maxWidth = ctx.page.pageFormat.availableWidth;
              final aspectRatio = totalWidth / treeHeight;
              final height = maxWidth / aspectRatio;
              return pw.Center(
                child: pw.Image(pwImage, width: maxWidth, height: height),
              );
            },
          ),
        );

        final file = File('${downloadsDir.path}/huffman_tree_$timestamp.pdf');
        await file.writeAsBytes(await pdf.save());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF saved to ${file.path}')));
      } else {
        // Save as PNG
        final file = File('${downloadsDir.path}/huffman_tree_$timestamp.png');
        await file.writeAsBytes(pngBytes);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PNG saved to ${file.path}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14.4.w),
      child:
          compressionSteps.isEmpty
              ? _buildPlaceholder(
                'Select an image to see Huffman tree visualization',
                screenSize,
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVisualizationControls(screenSize),
                  SizedBox(height: screenSize.height * 0.02),
                  Expanded(child: _buildHuffmanVisualization(screenSize)),
                  SizedBox(height: screenSize.height * 0.01),
                  if (currentStep < compressionSteps.length - 1)
                    const Text(
                      'Merging nodes with lowest frequencies',
                      style: TextStyle(color: Colors.white70),
                    ),
                  if (currentStep == compressionSteps.length - 1)
                    const Text(
                      'Final Huffman tree',
                      style: TextStyle(color: Colors.white70),
                    ),
                  if (currentStep == compressionSteps.length - 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        _downloadTree(
                          context,
                          compressionSteps.last.first,
                          screenSize,
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download Tree'),
                    ),
                ],
              ),
    );
  }

  Widget _buildVisualizationControls(Size screenSize) {
    return Row(
      children: [
        Text(
          'Step ${currentStep + 1}/${compressionSteps.length}',
          style: TextStyle(fontSize: 10.4.sp, fontWeight: FontWeight.bold),
        ),
         SizedBox(width: 10.w,),
         IconButton(
          onPressed: currentStep > 0 ? onPreviousStep : null,
          icon: const Icon(Icons.skip_previous),
          tooltip: 'Previous step',
        ),
         IconButton(
          onPressed: onToggleAnimation,
          icon: Icon(isAnimating ? Icons.pause : Icons.play_arrow),
          tooltip: isAnimating ? 'Pause animation' : 'Play animation',
        ),
         IconButton(
          onPressed:
              currentStep < compressionSteps.length - 1 ? onNextStep : null,
          icon: const Icon(Icons.skip_next),
          tooltip: 'Next step',
        ),
        SizedBox(width: 5.w),
        Text('Speed:', style: TextStyle(fontSize: 10.sp)),
        SizedBox(width: 5.w),
        DropdownButton<double>(
          value: stepDuration,
          items:
              [0.5, 1.0, 2.0, 3.0].map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text('${s.toStringAsFixed(1)}s'),
                );
              }).toList(),
          onChanged: (val) {
            if (val != null) {
              onStepDurationChanged(val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildHuffmanVisualization(Size screenSize) {
    if (compressionSteps.isEmpty || currentStep >= compressionSteps.length) {
      return const Center(child: Text('No data to display'));
    }

    List<HuffmanNode> currentNodes = compressionSteps[currentStep];
    return Card(
      elevation: 8,
      color: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.4.w),
      ),
      child:
          currentStep == compressionSteps.length - 1
              ? _buildFinalTreeView(currentNodes.first, screenSize)
              : _buildNodesListView(currentNodes, screenSize),
    );
  }

  Widget _buildNodesListView(List<HuffmanNode> nodes, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(14.4.w),
      child: Column(
        children: [
          Text(
            'Priority Queue - ${nodes.length} nodes remaining',
            style: TextStyle(fontSize: 14.4.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 13.8.h),
          Expanded(
            child: ListView.builder(
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                HuffmanNode node = nodes[index];
                return Card(
                      margin: EdgeInsets.symmetric(vertical: 3.45.h),
                      color:
                          node.pixelValue != null
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.deepPurple.withOpacity(0.2),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              node.pixelValue != null
                                  ? Colors.blue.shade700
                                  : Colors.deepPurple.shade700,
                          child: Text(
                            node.getCode(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          node.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          'Frequency: ${node.frequency}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.2, end: 0, duration: 300.ms);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalTreeView(HuffmanNode root, Size screenSize) {
    double nodeSpacing = 60.0.w;
    double horizontalMargin = 40.0.w;
    double estimatedWidth =
        TreeWidthCalculator.calculateTreeWidth(root, nodeSpacing) +
        horizontalMargin * 2;
    estimatedWidth = max(estimatedWidth, screenSize.width);

    return Padding(
      padding: EdgeInsets.all(14.4.w),
      child: Column(
        children: [
          Text(
            'Final Huffman Tree',
            style: TextStyle(fontSize: 14.4.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 13.8.h),
          Expanded(
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.01,
              maxScale: 5.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return CustomPaint(
                        key: _treeBoundaryKey,
                        size: Size(
                          estimatedWidth - horizontalMargin * 2,
                          screenSize.height * 1.5,
                        ),
                        painter: HuffmanTreePainter(root, animation.value),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

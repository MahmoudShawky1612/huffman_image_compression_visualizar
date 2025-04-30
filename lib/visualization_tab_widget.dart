import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'huffman_class.dart';
import 'huffman_tree_painter.dart';
import 'tree_width_calculator.dart';

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

  const VisualizationTabWidget({
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
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
                ],
              ),
    );
  }

  Widget _buildVisualizationControls(Size screenSize) {
    return Row(
      children: [
        Text(
          'Step ${currentStep + 1}/${compressionSteps.length}',
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: currentStep > 0 ? onPreviousStep : null,
          icon: const Icon(Icons.skip_previous),
          tooltip: 'Previous step',
        ),
        SizedBox(width: screenSize.width * 0.02),
        IconButton(
          onPressed: onToggleAnimation,
          icon: Icon(isAnimating ? Icons.pause : Icons.play_arrow),
          tooltip: isAnimating ? 'Pause animation' : 'Play animation',
        ),
        SizedBox(width: screenSize.width * 0.02),
        IconButton(
          onPressed:
              currentStep < compressionSteps.length - 1 ? onNextStep : null,
          icon: const Icon(Icons.skip_next),
          tooltip: 'Next step',
        ),
        const SizedBox(width: 16),
        Text('Speed:'),
        const SizedBox(width: 8),
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
        borderRadius: BorderRadius.circular(screenSize.width * 0.04),
      ),
      child:
          currentStep == compressionSteps.length - 1
              ? _buildFinalTreeView(currentNodes.first, screenSize)
              : _buildNodesListView(currentNodes, screenSize),
    );
  }

  Widget _buildNodesListView(List<HuffmanNode> nodes, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        children: [
          Text(
            'Priority Queue - ${nodes.length} nodes remaining',
            style: TextStyle(
              fontSize: screenSize.width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          Expanded(
            child: ListView.builder(
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                HuffmanNode node = nodes[index];
                return Card(
                      margin: EdgeInsets.symmetric(
                        vertical: screenSize.height * 0.005,
                      ),
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
    double nodeSpacing = 60.0;
    double horizontalMargin = 40.0;
    double estimatedWidth =
        TreeWidthCalculator.calculateTreeWidth(root, nodeSpacing) +
        horizontalMargin * 2;
    estimatedWidth = max(estimatedWidth, screenSize.width);

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        children: [
          Text(
            'Final Huffman Tree',
            style: TextStyle(
              fontSize: screenSize.width * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
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

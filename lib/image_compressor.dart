import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'app_bar_widget.dart';
import 'details_tab_widget.dart';
import 'home_tab_widget.dart';
import 'huffman_class.dart';
import 'image_utils.dart';
import 'status_bar_widget.dart';
import 'visualization_tab_widget.dart';

class ImageCompressor extends StatefulWidget {
  const ImageCompressor({super.key});

  @override
  State<ImageCompressor> createState() => _ImageCompressorState();
}

class _ImageCompressorState extends State<ImageCompressor>
    with TickerProviderStateMixin {
  File? originalImage;
  File? grayscaleImage;
  Map<int, int>? histogram;
  Map<int, String>? huffmanCodes;
  String? compressedBitstream;
  double? compressionRatio;
  double stepDuration = 1.0;

  late TabController _tabController;
  late AnimationController _treeAnimationController;
  late Animation<double> _treeAnimation;

  List<List<HuffmanNode>> compressionSteps = [];
  int currentStep = 0;
  bool isAnimating = false;
  Timer? animationTimer;

  bool isLoading = false;
  String statusMessage = "Select an image to begin";
  bool isProcessingComplete = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _treeAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _treeAnimation = CurvedAnimation(
      parent: _treeAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    _tabController.dispose();
    _treeAnimationController.dispose();
    super.dispose();
  }

  Future<void> pickAndProcessImage() async {
    try {
      setState(() {
        isLoading = true;
        statusMessage = "Selecting image...";
        isProcessingComplete = false;
        compressionSteps = [];
        currentStep = 0;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) {
        setState(() {
          isLoading = false;
          statusMessage = "Image selection cancelled";
        });
        return;
      }

      File file = File(result.files.single.path!);
      setState(() {
        originalImage = file;
        statusMessage = "Converting to grayscale...";
      });

      File? grayscale = await convertToGrayscale(file);
      if (grayscale == null) {
        setState(() {
          isLoading = false;
          statusMessage = "Failed to convert image to grayscale";
        });
        return;
      }

      setState(() {
        grayscaleImage = grayscale;
        statusMessage = "Building Huffman tree...";
      });

      final image = await decodeImage(grayscale);
      if (image == null) {
        setState(() {
          isLoading = false;
          statusMessage = "Failed to decode image";
        });
        return;
      }

      Map<int, int> hist = calculateHistogram(image);
      await buildHuffmanTreeWithVisualization(hist);

      HuffmanNode tree = compressionSteps.last.first;
      Map<int, String> codes = generateHuffmanCodes(tree);

      setState(() {
        statusMessage = "Compressing image...";
      });

      String bitstream = compressImage(image, codes);

      // Calculate sizes for display
      int originalSizeBytes = image.width * image.height;
      int compressedSizeBytes = (bitstream.length / 8).ceil();
      double ratio = originalSizeBytes / compressedSizeBytes.toDouble();

      setState(() {
        histogram = hist;
        huffmanCodes = codes;
        compressedBitstream = bitstream;
        compressionRatio = ratio;
        isLoading = false;
        statusMessage =
            "Compression complete! Original: $originalSizeBytes bytes, Compressed: $compressedSizeBytes bytes.";
        isProcessingComplete = true;
        _tabController.animateTo(1);
        _treeAnimationController.forward();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        statusMessage = "Error: $e";
      });
    }
  }

  Future<void> buildHuffmanTreeWithVisualization(
    Map<int, int> histogram,
  ) async {
    compressionSteps = [];
    var pq = PriorityQueue<HuffmanNode>(
      (a, b) => a.frequency.compareTo(b.frequency),
    );
    histogram.forEach((pixelValue, frequency) {
      pq.add(HuffmanNode(pixelValue, frequency));
    });
    compressionSteps.add(List<HuffmanNode>.from(pq.toList()));
    while (pq.length > 1) {
      var left = pq.removeFirst();
      var right = pq.removeFirst();
      var parent = HuffmanNode(
        null,
        left.frequency + right.frequency,
        left,
        right,
      );
      pq.add(parent);
      var currentQueue = List<HuffmanNode>.from(pq.toList());
      currentQueue.sort((a, b) => a.frequency.compareTo(b.frequency));
      compressionSteps.add(currentQueue);
    }
    if (pq.isNotEmpty) {
      compressionSteps.add([pq.first]);
    }
  }

  void startAnimation() {
    if (compressionSteps.isEmpty) return;
    setState(() {
      isAnimating = true;
      currentStep = 0;
    });
    animationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        if (currentStep < compressionSteps.length - 1) {
          currentStep++;
        } else {
          timer.cancel();
          isAnimating = false;
          _treeAnimationController.forward();
        }
      });
    });
  }

  void stopAnimation() {
    animationTimer?.cancel();
    setState(() {
      isAnimating = false;
    });
  }

  void updateStep(int newStep) {
    if (newStep >= 0 && newStep < compressionSteps.length) {
      setState(() {
        currentStep = newStep;
      });
    }
  }

  void updateStepDuration(double newDuration) {
    setState(() {
      stepDuration = newDuration;
      if (isAnimating) {
        stopAnimation();
        startAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.indigo.shade900],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBarWidget(
                screenSize: screenSize,
                tabController: _tabController,
                isLoading: isLoading,
                onPickImage: pickAndProcessImage,
              ),
              StatusBarWidget(
                screenSize: screenSize,
                isLoading: isLoading,
                statusMessage: statusMessage,
                compressionRatio: compressionRatio,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    HomeTabWidget(
                      screenSize: screenSize,
                      originalImage: originalImage,
                      grayscaleImage: grayscaleImage,
                      compressionRatio: compressionRatio,
                    ),
                    VisualizationTabWidget(
                      screenSize: screenSize,
                      compressionSteps: compressionSteps,
                      currentStep: currentStep,
                      isAnimating: isAnimating,
                      stepDuration: stepDuration,
                      animation: _treeAnimation,
                      onPreviousStep: () => updateStep(currentStep - 1),
                      onNextStep: () => updateStep(currentStep + 1),
                      onToggleAnimation:
                          isAnimating ? stopAnimation : startAnimation,
                      onStepDurationChanged: updateStepDuration,
                    ),
                    DetailsTabWidget(
                      screenSize: screenSize,
                      huffmanCodes: huffmanCodes,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

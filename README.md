
Huffman Image Compressor is a Flutter-based application that compresses grayscale images using the Huffman coding algorithm. The app provides a visual representation of the Huffman tree-building process and allows users to download the final Huffman tree as a PDF or PNG.

## Features

- **Image Selection**: Select an image from your device to compress.
- **Grayscale Conversion**: Automatically converts the selected image to grayscale.
- **Huffman Tree Visualization**: Displays the step-by-step process of building the Huffman tree.
- **Compression Details**: Shows the compression ratio and Huffman codes for each pixel value.
- **Download Huffman Tree**: Save the final Huffman tree as a PDF or PNG in the `Downloads` directory.

## Screenshots

### Home Screen
![Screenshot_2025-04-30-06-26-20-82_0f2d7d5cbe181983326ccc95b3097528](https://github.com/user-attachments/assets/d4e2aeec-f8d0-4f2d-8cf0-e2155a6cfdab)


### Huffman Tree Visualization
![Screenshot_2025-04-30-06-26-30-04_0f2d7d5cbe181983326ccc95b3097528](https://github.com/user-attachments/assets/563f81ab-b135-405d-b5e6-70c53ad54d92)

![Screenshot_2025-04-30-06-26-38-51_0f2d7d5cbe181983326ccc95b3097528](https://github.com/user-attachments/assets/0daa5e72-17e5-41d8-94b2-127f26ded19c)

### Compression Details
![Screenshot_2025-04-30-06-26-46-09_0f2d7d5cbe181983326ccc95b3097528](https://github.com/user-attachments/assets/223709fe-d557-4b28-b059-04baf42709fe)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/MahmoudShawky1612/huffman_image_compression_visualizar.git
   cd huffman_image_compression_visualizar
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. **Select an Image**:
   - Click the "Select Image" button on the home screen to choose an image from your device.

2. **View Huffman Tree**:
   - Navigate to the "Visualization" tab to see the step-by-step process of building the Huffman tree.

3. **Download Huffman Tree**:
   - Once the final Huffman tree is displayed, click the "Download Tree" button to save it as a PDF or PNG.

4. **View Compression Details**:
   - Navigate to the "Details" tab to see the Huffman codes and compression ratio.

## Project Structure

The project is organized into modular components for better maintainability:

- **`main.dart`**: Entry point of the application.
- **`image_compressor.dart`**: Main logic for image processing and Huffman compression.
- **`huffman_class.dart`**: Defines the `HuffmanNode` class used to build the Huffman tree.
- **`huffman_tree_painter.dart`**: Custom painter for rendering the Huffman tree.
- **`tree_width_calculator.dart`**: Utility for calculating the width of the Huffman tree.
- **`image_utils.dart`**: Utility functions for image decoding, grayscale conversion, and compression.
- **`visualization_tab_widget.dart`**: Handles the visualization of the Huffman tree.
- **`status_bar_widget.dart`**: Displays the status bar with progress and compression ratio.
- **`app_bar_widget.dart`**: Custom app bar with navigation and image selection.

## Dependencies

The project uses the following Flutter packages:

- [file_picker](https://pub.dev/packages/file_picker): For selecting images from the device.
- [image](https://pub.dev/packages/image): For image processing (grayscale conversion, pixel manipulation).
- [pdf](https://pub.dev/packages/pdf): For generating PDF files of the Huffman tree.
- [path_provider](https://pub.dev/packages/path_provider): For accessing the `Downloads` directory.
- [permission_handler](https://pub.dev/packages/permission_handler): For managing storage permissions.
- [flutter_animate](https://pub.dev/packages/flutter_animate): For animations in the UI.

## Permissions

The app requires the following permissions:

- **Storage Access**: To save the Huffman tree as a PDF or PNG in the `Downloads` directory.

For Android, ensure the following permissions are added to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
```

## Contributing

Contributions are welcome! If you'd like to contribute, please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any inquiries or feedback, please contact [mahmoudshawky1612@gmail.com].

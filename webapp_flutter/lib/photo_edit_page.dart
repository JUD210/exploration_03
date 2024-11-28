// photo_edit_page.dart

import 'package:flutter/material.dart';
import 'photo.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:path_provider/path_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // For color picker
import 'package:image/image.dart' as img; // For image processing
import 'package:image_picker/image_picker.dart'; // For picking background image

class PhotoEditPage extends StatefulWidget {
  final Photo photo;
  const PhotoEditPage({super.key, required this.photo});

  @override
  PhotoEditPageState createState() => PhotoEditPageState();
}

class PhotoEditPageState extends State<PhotoEditPage> {
  bool _isProcessing = false; // Processing state
  Uint8List? _editedImageBytes; // Edited image bytes
  Color _selectedColor = Colors.white; // Default background color
  Uint8List? _finalImageBytes; // Final image with background applied
  Uint8List? _backgroundImageBytes; // Background image bytes
  final ImagePicker _picker = ImagePicker(); // For picking images
  double _blurIntensity = 0.0; // Blur intensity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photo.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              Navigator.of(context)
                  .pop(widget.photo.id); // Return photo ID on delete
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_finalImageBytes != null)
              Expanded(
                flex: 4,
                child: Image.memory(_finalImageBytes!),
              )
            else if (_editedImageBytes != null)
              Expanded(
                flex: 4,
                child: Image.memory(_editedImageBytes!),
              )
            else
              Expanded(
                flex: 4,
                child: loadImage(widget.photo),
              ),
            const SizedBox(height: 20),
            Text(
              widget.photo.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_editedImageBytes != null)
              Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text('Select Background Image',
                        style: TextStyle(color: Colors.white)),
                    onPressed: _isProcessing ? null : _pickBackgroundImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.color_lens, color: Colors.white),
                    label: const Text('Select Background Color',
                        style: TextStyle(color: Colors.white)),
                    onPressed: _isProcessing ? null : _pickColor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_backgroundImageBytes != null ||
                      _selectedColor != Colors.white)
                    Column(
                      children: [
                        Text('Adjust Background Blur'),
                        Slider(
                          value: _blurIntensity,
                          min: 0.0,
                          max: 10.0,
                          divisions: 20,
                          label: _blurIntensity.toStringAsFixed(1),
                          onChanged: _isProcessing
                              ? null
                              : (value) {
                                  setState(() {
                                    _blurIntensity = value;
                                  });
                                  if (_backgroundImageBytes != null) {
                                    _applyBackgroundImage(
                                        _backgroundImageBytes!);
                                  } else {
                                    _applyBackgroundColor(_selectedColor);
                                  }
                                },
                        ),
                      ],
                    ),
                  if (_selectedColor != Colors.white)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Remove Background',
                  style: TextStyle(color: Colors.white)),
              onPressed: _isProcessing ? null : _removeBackground,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 24),
            if (_isProcessing) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _removeBackground() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final file = File(widget.photo.url);
      if (!file.existsSync()) {
        debugPrint(
            'Error: Image file does not exist at path: ${widget.photo.url}');
        return;
      }
      Uint8List imageBytes = await file.readAsBytes();

      // Send the image to the FastAPI server
      var uri =
          // Replace with your FastAPI server URL
          Uri.parse('https://13e3-220-117-157-240.ngrok-free.app/remove_bg');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes('file', imageBytes,
            filename: 'image.jpg', contentType: MediaType('image', 'jpeg')));

      debugPrint('Sending image to server for background removal...');
      var response = await request.send();

      if (response.statusCode == 200) {
        // Read the response bytes
        final responseBytes = await response.stream.toBytes();
        setState(() {
          _editedImageBytes = responseBytes;
          _finalImageBytes = responseBytes; // Initialize final image bytes
        });

        // Optionally, save the edited image to a file
        final directory = await getApplicationDocumentsDirectory();
        final editedImagePath =
            '${directory.path}/edited_${widget.photo.id}.png';
        File editedImageFile = File(editedImagePath);
        await editedImageFile.writeAsBytes(responseBytes);
        debugPrint('Edited image saved at $editedImagePath');
      } else {
        debugPrint(
            'Failed to remove background. Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error during background removal: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickBackgroundImage() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        Uint8List bgImageBytes = await image.readAsBytes();
        _backgroundImageBytes = bgImageBytes;
        await _applyBackgroundImage(bgImageBytes);
      } else {
        debugPrint('No background image selected.');
      }
    } catch (e) {
      debugPrint('Error picking background image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _applyBackgroundImage(Uint8List bgImageBytes) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (_editedImageBytes != null) {
        // Decode images
        img.Image? foreground = img.decodeImage(_editedImageBytes!);
        img.Image? background = img.decodeImage(bgImageBytes);

        if (foreground != null && background != null) {
          // Resize background to match foreground size
          background = img.copyResize(background,
              width: foreground.width, height: foreground.height);

          // Apply blur to background
          if (_blurIntensity > 0) {
            background = img.gaussianBlur(background, _blurIntensity.toInt());
          }

          // Composite the foreground onto the background
          img.drawImage(background, foreground);

          // Encode the final image to PNG
          Uint8List finalBytes = Uint8List.fromList(img.encodePng(background));
          setState(() {
            _finalImageBytes = finalBytes;
          });
        } else {
          debugPrint('Error decoding images.');
        }
      }
    } catch (e) {
      debugPrint('Error applying background image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickColor() async {
    Color pickedColor = _selectedColor;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a Background Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                pickedColor = color;
              },
              enableAlpha: false,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Apply the selected color as background
    await _applyBackgroundColor(pickedColor);
  }

  Future<void> _applyBackgroundColor(Color color) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (_editedImageBytes != null) {
        // Use the 'image' package to process the image
        img.Image? image = img.decodeImage(_editedImageBytes!);
        if (image != null) {
          // Create a new image with the same dimensions and the selected background color
          img.Image background = img.Image(image.width, image.height);
          background.fill(img.getColor(color.red, color.green, color.blue));

          // Apply blur to background color if needed
          if (_blurIntensity > 0) {
            background = img.gaussianBlur(background, _blurIntensity.toInt());
          }

          // Composite the foreground image onto the background
          img.drawImage(background, image);

          // Encode the final image to PNG
          Uint8List finalBytes = Uint8List.fromList(img.encodePng(background));
          setState(() {
            _finalImageBytes = finalBytes;
            _selectedColor = color;
            _backgroundImageBytes = null; // Reset background image
          });
        }
      }
    } catch (e) {
      debugPrint('Error applying background color: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

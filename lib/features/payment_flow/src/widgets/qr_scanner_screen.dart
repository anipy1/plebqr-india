import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool popped = false;
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  late StreamSubscription<BarcodeCapture> _barcodeSubscription;

  @override
  void initState() {
    super.initState();
    _barcodeSubscription = cameraController.barcodes.listen(onDetect);
  }

  void onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final Barcode barcode in barcodes) {
      if (popped || !mounted) {
        return;
      }
      final String? code = barcode.rawValue;
      if (code == null) {
        // Failed to scan QR code
      } else {
        popped = true;
        Navigator.of(context).pop(code);
      }
    }
  }

  @override
  void dispose() {
    _barcodeSubscription.cancel();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: MobileScanner(key: qrKey, controller: cameraController),
          ),
          const ScanOverlay(),
          SafeArea(
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 10,
                  top: 5,
                  child: ImagePickerButton(
                    cameraController: cameraController,
                    onDetect: onDetect,
                  ),
                ),
                Positioned(
                  bottom: 30.0,
                  right: 0,
                  left: 0,
                  child: QrScanCancelButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePickerButton extends StatelessWidget {
  const ImagePickerButton({
    required this.cameraController,
    required this.onDetect,
    super.key,
  });

  final MobileScannerController cameraController;
  final void Function(BarcodeCapture capture) onDetect;

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return IconButton(
      padding: const EdgeInsets.fromLTRB(0, 32, 24, 0),
      icon: const Icon(Icons.image, color: Colors.white, size: 32),
      onPressed: () async {
        final ImagePicker picker = ImagePicker();

        final XFile? image = await picker
            .pickImage(source: ImageSource.gallery)
            .catchError((Object err) {
              return null;
            });

        if (image == null) {
          return;
        }

        final String filePath = image.path;

        final BarcodeCapture? barcodes = await cameraController
            .analyzeImage(filePath)
            .catchError((Object err) {
              return null;
            });

        if (barcodes == null) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('No QR code found in image')),
          );
        } else {
          onDetect(barcodes);
        }
      },
    );
  }
}

class QrScanCancelButton extends StatelessWidget {
  const QrScanCancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 35),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final double dimension = MediaQuery.of(context).size.width - 72;
    return Center(
      child: CustomPaint(
        painter: BorderPainter(),
        child: SizedBox(width: dimension, height: dimension),
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double width = 4.0;
    const double radius = 16.0;
    const double tRadius = 2 * radius;
    final Rect rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(radius),
    );
    const Rect clippingRect0 = Rect.fromLTWH(0, 0, tRadius, tRadius);
    final Rect clippingRect1 = Rect.fromLTWH(
      size.width - tRadius,
      0,
      tRadius,
      tRadius,
    );
    final Rect clippingRect2 = Rect.fromLTWH(
      0,
      size.height - tRadius,
      tRadius,
      tRadius,
    );
    final Rect clippingRect3 = Rect.fromLTWH(
      size.width - tRadius,
      size.height - tRadius,
      tRadius,
      tRadius,
    );

    final Path path =
        Path()
          ..addRect(clippingRect0)
          ..addRect(clippingRect1)
          ..addRect(clippingRect2)
          ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

import 'dart:io';

import 'package:camera/camera.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF209DD7)),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CameraGuidePage(),
    );
  }
}

class CameraGuidePage extends StatefulWidget {
  const CameraGuidePage({super.key});

  @override
  State<CameraGuidePage> createState() => _CameraGuidePageState();
}

class _CameraGuidePageState extends State<CameraGuidePage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  Future<void>? _cameraDisposal;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _photos = [];
  XFile? _overlayImage;
  double _overlayOpacity = 0.45;
  bool _isCapturing = false;
  bool _isInitializingCamera = false;
  bool _isSwitchingCamera = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_cameraController != null ||
        _isInitializingCamera ||
        _isSwitchingCamera) {
      return;
    }

    _isInitializingCamera = true;
    try {
      await _cameraDisposal;
      final cameras = await availableCameras();
      _cameras = cameras;
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _error = 'No camera available');
        }
        return;
      }
      _cameras = cameras;
      if (_selectedCameraIndex >= cameras.length) {
        _selectedCameraIndex = 0;
      }
      final controller = CameraController(
        cameras[_selectedCameraIndex],
        ResolutionPreset.max,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Camera permission was not granted');
      }
    } finally {
      _isInitializingCamera = false;
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isSwitchingCamera) {
      return;
    }

    final previousController = _cameraController;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() {
      _cameraController = null;
      _selectedCameraIndex = nextIndex;
      _isSwitchingCamera = true;
    });

    try {
      _cameraDisposal = previousController?.dispose();
      await _cameraDisposal;
      final controller = CameraController(
        _cameras[nextIndex],
        ResolutionPreset.max,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not switch camera');
      }
    } finally {
      if (mounted) {
        setState(() => _isSwitchingCamera = false);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final controller = _cameraController;
      if (controller != null) {
        setState(() => _cameraController = null);
        _cameraDisposal = controller.dispose();
      }
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);
    try {
      final photo = await controller.takePicture();
      await Gal.putImage(photo.path);
      if (mounted) {
        setState(() => _photos.insert(0, photo.path));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not save photo')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _chooseOverlay() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (!mounted) {
      return;
    }
    if (_cameraController == null) {
      await _initializeCamera();
    }
    if (image != null && mounted) {
      setState(() => _overlayImage = image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          key: const Key('camera-stage'),
          fit: StackFit.expand,
          children: [
            if (_cameraController?.value.isInitialized == true)
              LayoutBuilder(
                builder: (context, constraints) {
                  final controller = _cameraController!;
                  final cameraAspectRatio = controller.value.aspectRatio;
                  final previewAspectRatio =
                      MediaQuery.orientationOf(context) == Orientation.landscape
                      ? cameraAspectRatio
                      : 1 / cameraAspectRatio;

                  return FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxWidth / previewAspectRatio,
                      child: CameraPreview(controller),
                    ),
                  );
                },
              )
            else
              Center(
                child: Text(
                  _error ?? 'Starting camera...',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  key: const Key('guide-overlay-opacity'),
                  opacity: _overlayOpacity,
                  child: _overlayImage == null
                      ? Image.asset('esboco.jpg', fit: BoxFit.contain)
                      : Image.file(
                          File(_overlayImage!.path),
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _cameras.length > 1 && !_isSwitchingCamera
                      ? _switchCamera
                      : null,
                  icon: const Icon(Icons.flip_camera_android),
                  color: Colors.white,
                  tooltip: 'Switch camera',
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 136,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.opacity, color: Colors.white70, size: 20),
                    Expanded(
                      child: Slider(
                        value: _overlayOpacity,
                        min: 0,
                        max: 1,
                        divisions: 20,
                        label: '${(_overlayOpacity * 100).round()}%',
                        semanticFormatterCallback: (value) =>
                            '${(value * 100).round()} percent',
                        onChanged: (value) {
                          setState(() => _overlayOpacity = value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${(_overlayOpacity * 100).round()}%',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.black87],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _chooseOverlay,
                      icon: const Icon(Icons.photo_library),
                      color: const Color(0xFFECAD0A),
                      iconSize: 32,
                      tooltip: 'Choose guide image',
                    ),
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        itemCount: _photos.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    FullscreenPhoto(path: _photos[index]),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(_photos[index]),
                                width: 104,
                                height: 104,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FloatingActionButton(
                        onPressed: _isCapturing ? null : _capturePhoto,
                        backgroundColor: const Color(0xFF209DD7),
                        foregroundColor: Colors.white,
                        tooltip: 'Take photo',
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullscreenPhoto extends StatelessWidget {
  const FullscreenPhoto({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Center(child: Image.file(File(path))),
      ),
    );
  }
}

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pfe_flutter/features/3photo/view_model/face_capture_view_model.dart';
import 'package:pfe_flutter/shared/app_colors.dart';



class Take3PhotoPage extends StatefulWidget {
  const Take3PhotoPage({super.key});

  @override
  State<Take3PhotoPage> createState() => _Take3PhotoPageState();
}

class _Take3PhotoPageState extends State<Take3PhotoPage> {
  late final FaceCaptureViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = FaceCaptureViewModel();
    _viewModel.addListener(_updateUI);
    _viewModel.initialize(); // async
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_updateUI);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _viewModel.state;
    final controller = _viewModel.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prendre 3 photos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Aperçu caméra + cercle
              controller != null && controller.value.isInitialized
                  ? SizedBox(
                      width: 300,
                      height: 400,
                      child: Stack(
                        children: [
                          CameraPreview(controller),
                          Center(
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.greenAccent,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),

              const SizedBox(height: 20),

              // Direction détectée
              Text(
                'Direction du visage : ${state.faceDirection}',
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 20),

              // Photos prises
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  if (state.facePhotoPath != null)
                    Column(
                      children: [
                        const Text('Photo Face'),
                        Image.file(File(state.facePhotoPath!), width: 100, height: 100),
                      ],
                    ),
                  if (state.frontFaceExtracted != null)
                    Column(
                      children: [
                        const Text('Visage extrait'),
                        Image.file(state.frontFaceExtracted!, width: 100, height: 100),
                      ],
                    ),
                  if (state.gauchePhotoPath != null)
                    Column(
                      children: [
                        const Text('Photo Gauche'),
                        Image.file(File(state.gauchePhotoPath!), width: 100, height: 100),
                      ],
                    ),
                  if (state.droitePhotoPath != null)
                    Column(
                      children: [
                        const Text('Photo Droite'),
                        Image.file(File(state.droitePhotoPath!), width: 100, height: 100),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
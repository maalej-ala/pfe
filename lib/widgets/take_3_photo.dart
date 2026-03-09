import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:pfe_flutter/features/face_detection/camera_service.dart';
import 'package:pfe_flutter/features/face_detection/face_detection_service.dart';

// Page pour prendre 3 photos (face, gauche, droite) automatiquement
class Take3Photo extends StatefulWidget {
	const Take3Photo({super.key});

	@override
	State<Take3Photo> createState() => _Take3PhotoState();
}

class _Take3PhotoState extends State<Take3Photo> {
	// Services pour la caméra et la détection faciale
	final CameraService _cameraService = CameraService();
	final FaceDetectionService _faceService = FaceDetectionService();

	// Variables d'état pour le contrôle du flux
	bool _isDetecting = false;      // Empêche les détections simultanées
	String _faceDirection = '';      // Direction détectée du visage
	bool _isCapturing = false;       // Empêche les captures multiples

	// Chemins des photos prises
	String? _facePhotoPath;          // Photo de face
	String? _gauchePhotoPath;        // Photo profil gauche
	String? _droitePhotoPath;        // Photo profil droite
  File?  _frontFaceExtracted; // Image du visage extrait de la photo de face
	@override
	void initState() {
		super.initState();
		_setupCamera();  // Initialise la caméra au démarrage
	}

	// Configure et démarre la caméra
	Future<void> _setupCamera() async {
		// Récupère toutes les caméras disponibles
		final cameras = await availableCameras();
		// Cherche la caméra frontale, sinon prend la première
		final camera = cameras.firstWhere(
			(c) => c.lensDirection == CameraLensDirection.front,
			orElse: () => cameras.first,
		);

		// Initialise le service caméra
		await _cameraService.initializeCamera(camera);
		// Démarre le flux d'images pour l'analyse en temps réel
		_cameraService.startImageStream(_processCameraImage);

		setState(() {});  // Rafraîchit l'interface
	}

	// Traite chaque image de la caméra pour détecter les visages
	void _processCameraImage(InputImage inputImage) async {
		if (_isDetecting) return;  // Évite la surcharge de traitement
		_isDetecting = true;

		try {
			// Détecte les visages dans l'image
			final faces = await _faceService.getFaces(inputImage);
			if (faces.isNotEmpty) {
				// Prend le premier visage détecté
				final face = faces.first;
				final faceRect = face.boundingBox;  // Rectangle autour du visage
				
				// Dimensions réelles de l'image caméra
				final imageWidth = inputImage.metadata?.size.width ?? 0;
				final imageHeight = inputImage.metadata?.size.height ?? 0;
				
				// Dimensions fixes de l'aperçu à l'écran
				const previewWidth = 300.0;
				const previewHeight = 400.0;
				
				if (imageWidth == 0 || imageHeight == 0) return;
				
				// Facteurs de conversion (coordonnées caméra → coordonnées écran)
				final scaleX = previewWidth / imageWidth;
				final scaleY = previewHeight / imageHeight;
				
				// Centre du visage en coordonnées écran
				final faceCenterX = faceRect.center.dx * scaleX;
				final faceCenterY = faceRect.center.dy * scaleY;
				
				// Centre du cercle guide (milieu de l'écran)
				const circleCenterX = previewWidth / 2;
				const circleCenterY = previewHeight / 2;
				const circleRadius = 100.0;  // Rayon du cercle de détection
				
				// Distance entre le centre du visage et le centre du cercle
				final distance = sqrt(
					pow(faceCenterX - circleCenterX, 2) +
					pow(faceCenterY - circleCenterY, 2)
				);
				
				// Taille du visage à l'écran
				final faceWidth = faceRect.width * scaleX;
				final faceHeight = faceRect.height * scaleY;
				final faceRadius = (faceWidth + faceHeight) / 4;  // Rayon moyen
				
				// Vérifie si le visage est dans le cercle (avec tolérance)
				bool isInCircle;
				if (faceWidth > circleRadius * 1.5) {
					// Si le visage est plus grand que le cercle
					isInCircle = distance <= circleRadius * 0.8;
				} else {
					// Si le visage est plus petit que le cercle
					isInCircle = distance <= circleRadius + faceRadius * 0.5;
				}
				
				if (isInCircle) {
					// Visage bien positionné, on détecte sa direction
					final direction = await _faceService.detectFaceDirection(inputImage);
					if (mounted) setState(() => _faceDirection = direction);
					
					// Capture selon la direction si pas déjà fait
					if (direction == 'Front' && _facePhotoPath == null) {
						await _capturePhotoForDirection('Front');
					} else if (direction == 'Gauche' && _gauchePhotoPath == null) {
						await _capturePhotoForDirection('Gauche');
					} else if (direction == 'Droite' && _droitePhotoPath == null) {
						await _capturePhotoForDirection('Droite');
					}
				} else {
					// Visage pas dans le cercle
					if (mounted) setState(() => _faceDirection = 'Positionnez le visage dans le cercle');
				}
			} else {
				// Aucun visage détecté
				if (mounted) setState(() => _faceDirection = 'Aucun visage détecté');
			}
		} catch (e) {
			// Gestion des erreurs de détection
			debugPrint("Erreur MLKit: $e");
			if (mounted) setState(() => _faceDirection = 'Erreur de détection');
		} finally {
			_isDetecting = false;  // Permet de traiter l'image suivante
		}
	}

	// Prend une photo pour la direction spécifiée
	Future<void> _capturePhotoForDirection(String direction) async {
  final controller = _cameraService.controller;

  if (controller == null || !controller.value.isInitialized) return;
  if (_isCapturing) return;

  _isCapturing = true;

  try {
    await Future.delayed(const Duration(milliseconds: 300));

    final file = await controller.takePicture();

    File? extractedFace;

    // extraction visage uniquement pour la face front
    if (direction == 'Front') {
      extractedFace = await _faceService.extractFaceFromFile(File(file.path));
    }

    if (mounted) {
      setState(() {

        if (direction == 'Front') {
          _facePhotoPath = file.path;
          _frontFaceExtracted = extractedFace;
        }

        else if (direction == 'Gauche') {
          _gauchePhotoPath = file.path;
        }

        else if (direction == 'Droite') {
          _droitePhotoPath = file.path;
        }

      });
    }

    debugPrint('Photo prise pour $direction: ${file.path}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Photo $direction prise !'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );

  } catch (e) {

    debugPrint('Erreur lors de la capture: $e');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

  } finally {
    _isCapturing = false;
  }
}

	// Libère les ressources à la destruction du widget
	@override
	void dispose() {
		_cameraService.dispose();
		_faceService.dispose();
		super.dispose();
	}

	// Construction de l'interface utilisateur
	@override
	Widget build(BuildContext context) {
		final controller = _cameraService.controller;
		return Scaffold(
			appBar: AppBar(title: const Text('Prendre 3 photos')), // Titre fixe
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16.0),
				child: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							// Aperçu caméra avec cercle guide
							controller != null && controller.value.isInitialized
									? SizedBox(
											width: 300,
											height: 400,
											child: Stack(
												children: [
													CameraPreview(controller),  // Flux caméra
													// Cercle guide superposé
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
									: const CircularProgressIndicator(),  // Chargement
							
							const SizedBox(height: 20),
							
							// Affichage de la direction détectée
							Text('Direction du visage : $_faceDirection', style: const TextStyle(fontSize: 20)),
							
							const SizedBox(height: 20),
							
							// Affichage des 3 photos prises
							Wrap(
  spacing: 16,
  runSpacing: 16,
  alignment: WrapAlignment.center,
  children: [

    if (_facePhotoPath != null)
      Column(
        children: [
          const Text('Photo Face'),
          Image.file(File(_facePhotoPath!), width: 100, height: 100),
        ],
      ),

    if (_frontFaceExtracted != null)
      Column(
        children: [
          const Text('Visage extrait'),
          Image.file(_frontFaceExtracted!, width: 100, height: 100),
        ],
      ),

    if (_gauchePhotoPath != null)
      Column(
        children: [
          const Text('Photo Gauche'),
          Image.file(File(_gauchePhotoPath!), width: 100, height: 100),
        ],
      ),

    if (_droitePhotoPath != null)
      Column(
        children: [
          const Text('Photo Droite'),
          Image.file(File(_droitePhotoPath!), width: 100, height: 100),
        ],
      ),
  ],
),
							const SizedBox(height: 20),
						],
					),
				),
			),
		);
	}
}
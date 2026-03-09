import 'dart:io'; // Permet de manipuler des fichiers (File)
import 'package:flutter/material.dart'; // Widgets Flutter (Scaffold, Container, etc.)
import 'package:camera/camera.dart'; // Plugin Flutter pour accéder à la caméra
import 'package:image/image.dart' as img; // Librairie pour manipuler les images (crop, resize, etc.)
import 'package:pfe_flutter/features/face_detection/camera_service.dart'; // Service personnalisé pour gérer la caméra

// Page qui permet de scanner une carte et capturer son image
class CardScannerPage extends StatefulWidget {
  // Fonction callback qui retourne l'image capturée
  final Function(File imageFile) onPictureTaken;

  // Description de la caméra utilisée (avant / arrière)
  final CameraDescription camera;

  // Constructeur du widget
  const CardScannerPage({
    super.key,
    required this.onPictureTaken, // callback obligatoire
    required this.camera, // caméra obligatoire
  });

  @override
  State<CardScannerPage> createState() => _CardScannerPageState();
}

// State associé au StatefulWidget
class _CardScannerPageState extends State<CardScannerPage> {

  // Service qui gère la caméra
  final CameraService _cameraService = CameraService();

  // Indique si la caméra est prête
  bool _isInitialized = false;

  // Dimensions du rectangle affiché sur l'écran (zone de scan)
  final double rectWidth = 320;
  final double rectHeight = 200;

  // Taille réelle de la preview caméra
  Size? _cameraPreviewSize;

  @override
  void initState() {
    super.initState();

    // Initialisation de la caméra au démarrage de la page
    _initCamera();
  }

  // Fonction pour initialiser la caméra
  Future<void> _initCamera() async {

    // Appelle le service caméra
    await _cameraService.initializeCamera(widget.camera);

    // Vérifie si le widget est encore monté
    if (mounted) {
      setState(() {
        _isInitialized = true; // caméra prête
      });
    }
  }

  // Fonction pour prendre une photo
  Future<void> _takePicture() async {
    try {

      // Capture la photo
      final image = await _cameraService.controller!.takePicture();

      // Crop l'image selon le rectangle affiché
      File cropped = await _cropCard(File(image.path));

      // Envoie l'image au widget parent
      widget.onPictureTaken(cropped);

      // Ferme la page scanner
      if (mounted) Navigator.pop(context);

    } catch (e) {
      debugPrint("Erreur photo: $e");
    }
  }

  // Fonction pour découper (crop) la carte dans l'image
  Future<File> _cropCard(File file) async {
  // Lire l'image du fichier en bytes
  final bytes = await file.readAsBytes();

  // Convertir les bytes en image manipulable par la librairie 'image'
  img.Image? original = img.decodeImage(bytes);

  // Si l'image ne peut pas être décodée, retourner le fichier original
  if (original == null) return file;

  // Taille de la preview caméra (taille renvoyée par le CameraController)
  final previewSize = _cameraService.controller!.value.previewSize!;

  // Inversion width/height car la preview est souvent en landscape alors que le téléphone est en portrait
  final previewWidth = previewSize.height; // debug: 480.0
  final previewHeight = previewSize.width; // debug: 720.0

  // Taille réelle de l'écran du téléphone
  final screenSize = MediaQuery.of(context).size; // debug: 392.7 x 872.7

  // Calcul de la taille affichée de la preview caméra pour garder le ratio
  double displayedWidth = screenSize.width; // debug: 392.7
  double displayedHeight = displayedWidth * previewHeight / previewWidth; // debug: 589.09

  // Décalage vertical si la preview ne remplit pas tout l'écran (pour centrer la preview)
  double offsetY = (displayedHeight - screenSize.height) / 2; // debug: -141.82

  // Calcul de la position du rectangle de scan au centre de l'écran
  double left = (displayedWidth - rectWidth) / 2; // debug: 36.36
  double top = (screenSize.height - rectHeight) / 2 + offsetY; // debug: 194.54

  // Calcul des ratios pour convertir les coordonnées de l'écran vers l'image réelle
  final scaleX = original.width / displayedWidth; // debug: 1.222
  final scaleY = original.height / displayedHeight; // debug: 1.222

  // Calcul du rectangle de crop dans l'image originale
  int cropX = (left * scaleX).round(); // debug: 44
  int cropY = (top * scaleY).round(); // debug: 238
  int cropWidth = (rectWidth * scaleX).round(); // debug: 391
  int cropHeight = (rectHeight * scaleY).round(); // debug: 244

  // ===== DEBUG PRINTS =====
  debugPrint("===== CROP DEBUG =====");
  debugPrint("original width: ${original.width}"); // 480
  debugPrint("original height: ${original.height}"); // 720
  debugPrint("previewWidth: $previewWidth"); // 480.0
  debugPrint("previewHeight: $previewHeight"); // 720.0
  debugPrint("screen width: ${screenSize.width}"); // 392.7
  debugPrint("screen height: ${screenSize.height}"); // 872.7
  debugPrint("displayedWidth: $displayedWidth"); // 392.7
  debugPrint("displayedHeight: $displayedHeight"); // 589.09
  debugPrint("offsetY: $offsetY"); // -141.82
  debugPrint("rectWidth: $rectWidth"); // 320.0
  debugPrint("rectHeight: $rectHeight"); // 200.0
  debugPrint("left: $left"); // 36.36
  debugPrint("top: $top"); // 194.54
  debugPrint("scaleX: $scaleX"); // 1.222
  debugPrint("scaleY: $scaleY"); // 1.222
  debugPrint("cropX: $cropX"); // 44
  debugPrint("cropY: $cropY"); // 238
  debugPrint("cropWidth: $cropWidth"); // 391
  debugPrint("cropHeight: $cropHeight"); // 244
  debugPrint("======================");

  // Découpe de l'image selon les coordonnées calculées
  img.Image cropped = img.copyCrop(
    original,
    x: cropX,
    y: cropY,
    width: cropWidth,
    height: cropHeight,
  );

  // Sauvegarde de la nouvelle image dans un fichier avec suffixe "_crop.jpg"
  final croppedFile = File(file.path.replaceAll(".jpg", "_crop.jpg"));
  await croppedFile.writeAsBytes(img.encodeJpg(cropped));

  // Retourne le fichier découpé
  return croppedFile;
}
  @override
  void dispose() {

    // Libérer la caméra quand la page se ferme
    _cameraService.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Si la caméra n'est pas prête
    if (!_isInitialized || _cameraService.controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // loader
        ),
      );
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {

          // Sauvegarder la taille réelle de la preview
          WidgetsBinding.instance.addPostFrameCallback((_) {

            final previewSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            if (_cameraPreviewSize != previewSize) {
              setState(() {
                _cameraPreviewSize = previewSize;
              });
            }
          });

          return Stack(
            children: [

              // Preview caméra plein écran
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _cameraService.controller!.value.previewSize!.height,
                    height: _cameraService.controller!.value.previewSize!.width,
                    child: CameraPreview(_cameraService.controller!),
                  ),
                ),
              ),

              // Rectangle de scan au centre de l'écran
              Center(
                child: Container(
                  width: rectWidth,
                  height: rectHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Bouton pour capturer la photo
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: _takePicture, // capture
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
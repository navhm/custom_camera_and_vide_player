import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'uploading_screen.dart';

List<CameraDescription> cameras = [];

class CameraScreen extends StatefulWidget {
  static const String id = "camera_screen";

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  bool recordingStarted = false;
  bool pauseIcon = true;
  bool rearCameraSelected = true;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  bool isLoading = false;
  int _pointers = 0;

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    setState(() {
      isLoading = true; //Data is loading
    });
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    setState(() {
      isLoading = false; //Data has loaded
    });
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> toggleCamera() async {
    if (rearCameraSelected) {
      controller = CameraController(cameras[1], ResolutionPreset.medium);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          rearCameraSelected = false;
        });
      });
    } else {
      controller = CameraController(cameras[0], ResolutionPreset.max);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          rearCameraSelected = true;
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.addObserver(this);
    controller?.dispose();
    super.dispose();
  }

  //New ZOOM
  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  //New Pinch function
  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  // void onTakePictureButtonPressed() {
  //   takePicture().then((XFile? file) {
  //     if (mounted) {
  //       setState(() {
  //         imageFile = file;
  //         videoController?.dispose();
  //         videoController = null;
  //       });
  //       // if (file != null) showInSnackBar('Picture saved to ${file.path}');
  //     }
  //   });
  // }

  // Future<XFile?> takePicture() async {
  //   final CameraController? cameraController = controller;
  //   if (cameraController == null || !cameraController.value.isInitialized) {
  //     // showInSnackBar('Error: select a camera first.');
  //     return null;
  //   }
  //
  //   if (cameraController.value.isTakingPicture) {
  //     // A capture is already pending, do nothing.
  //     return null;
  //   }
  //
  //   try {
  //     XFile file = await cameraController.takePicture();
  //     return file;
  //   } on CameraException {
  //     // _showCameraException(e);
  //     return null;
  //   }
  // }

  void onVideoRecordButtonPressed() {
    setState(() {
      recordingStarted = true;
    });
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      // showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException {
      // _showCameraException(e);
      return;
    }
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted)
        setState(() {
          pauseIcon = false;
        });
      // showInSnackBar('Video recording paused');
    });
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException {
      // _showCameraException(e);
      rethrow;
    }
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted)
        setState(() {
          pauseIcon = true;
        });
      // showInSnackBar('Video recording resumed');
    });
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException {
      // _showCameraException(e);
      rethrow;
    }
  }

  void onStopButtonPressed() async {
    print('stop button pressed');
    setState(() {
      recordingStarted = false;
      pauseIcon = true;
    });
    stopVideoRecording().then((file) async {
      if (mounted) setState(() {});
      if (file != null) {
        // showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        // final appDir = await pathprovider.getApplicationDocumentsDirectory();
        // final fileName = path.basename(videoFile!.path);
        // final savedVideo =
        //     await File(videoFile!.path).copy('${appDir.path}/$fileName');

        _startVideoPlayer();
      }
    });
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException {
      // _showCameraException(e);
      return null;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      print("video file is null");
      return;
    }
    print("initializing videoPlayerController");
    final VideoPlayerController vController =
        VideoPlayerController.file(File(videoFile!.path));
    videoPlayerListener = () {
      if (videoController != null && videoController?.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(false);
    await vController.initialize();
    // await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          SizedBox(
              height: double.infinity,
              child: isLoading
                  ? Container(
                      color: Colors.black,
                      height: double.infinity,
                    )
                  : _cameraPreviewWidget()),
          Positioned(bottom: 120, child: _thumbnailWidget()),
          Positioned(bottom: 0, child: _captureControlRowWidget()),
          Positioned(
              top: 40,
              right: 30,
              child: (videoController == null)
                  ? Container()
                  : Material(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadingScreen(
                                videoFile: videoFile,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "POST",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    )),
        ],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    // final CameraController? cameraController = controller;

    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: CameraPreview(
        controller!,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onTapDown: (details) => onViewFinderTap(details, constraints),
          );
        }),
      ),
    );
  }

  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return localVideoController == null && imageFile == null
        ? Container()
        : SizedBox(
            child: (localVideoController == null)
                ? Image.file(File(imageFile!.path))
                : Container(
                    child: Center(
                      child: AspectRatio(
                          aspectRatio: localVideoController.value.size != null
                              ? localVideoController.value.aspectRatio
                              : 1.0,
                          child: VideoPlayer(localVideoController)),
                    ),
                  ),
            width: 180.0,
            height: 140.0,
          );
  }

  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;
    final bool recordingState = recordingStarted;
    final bool pauseButton = pauseIcon;

    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  recordingState
                      ? CircleAvatar(
                          backgroundColor: Colors.black12,
                          radius: 25,
                          child: IconButton(
                              onPressed: pauseButton
                                  ? cameraController != null &&
                                          cameraController
                                              .value.isInitialized &&
                                          cameraController
                                              .value.isRecordingVideo
                                      ? onPauseButtonPressed
                                      : null
                                  : cameraController != null &&
                                          cameraController
                                              .value.isInitialized &&
                                          !cameraController
                                              .value.isRecordingVideo
                                      ? null
                                      : onResumeButtonPressed,
                              icon: Icon(
                                pauseButton ? Icons.pause : Icons.play_arrow,
                                size: 30,
                                color: Colors.white,
                              )))
                      : SizedBox(
                          width: 50,
                        ),
                  CircleAvatar(
                    backgroundColor:
                        recordingState ? Colors.white : Colors.red[800],
                    radius: 35,
                    child: recordingState
                        ? IconButton(
                            onPressed: onStopButtonPressed,
                            icon: Icon(
                              Icons.stop,
                              size: 30,
                              color: Colors.red[800],
                            ))
                        : InkWell(
                            splashColor: Colors.red[800],
                            onTap: onVideoRecordButtonPressed,
                          ),
                  ),
                  IconButton(
                      onPressed: toggleCamera,
                      icon: Icon(
                        Icons.flip_camera_ios,
                        size: 30,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
//

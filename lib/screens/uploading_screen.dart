import 'dart:math';

import 'package:bc_assignment/screens/post_confirmation_screen.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'stream_page.dart';
import 'camera_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:bc_assignment/services/user_location.dart';
import 'package:bc_assignment/services/video_uploading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bc_assignment/services/video_details.dart';

class UploadingScreen extends StatefulWidget {
  final XFile? videoFile;
  UploadingScreen({required this.videoFile});
  @override
  _UploadingScreenState createState() => _UploadingScreenState();
}

class _UploadingScreenState extends State<UploadingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  var locationName;
  UploadTask? task;
  bool videoUploading = false;
  bool loadingLocation = false;
  bool loadingVideo = false;
  VoidCallback? videoPlayerListener;
  VideoPlayerController? videoController;
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  final referenceDatabase = FirebaseDatabase.instance;

  void uploadVideo() async {
    File file = File(widget.videoFile!.path);

    final fileName = basename(file.path);

    final destination = 'videos/$fileName';

    task = FirebaseApi.uploadFile(destination, file);

    if (task == null) return;

    final snapshot = await task!.whenComplete(() => videoUploading = false);

    final videoUrl = await snapshot.ref.getDownloadURL();

    final video = referenceDatabase.reference().child('videos');
    video.push().set({
      'title': _title.text,
      'description': _description.text,
      'userName': loggedInUser!.uid,
      'url': videoUrl,
      'location': locationName,
    });
    print('Download-Link : $videoUrl');

    _firestore.collection('videoinformation').add({
      'title': _title.text,
      'description': _description.text,
      'userName': loggedInUser!.uid,
      'location': locationName,
      'url': videoUrl,
    });
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser!.phoneNumber);
      }
    } catch (e) {
      print(e);
    }
  }

  void initState() {
    fetchData();
    getCurrentUser();
    super.initState();
  }

  fetchData() async {
    setState(() {
      loadingLocation = true;
      loadingVideo = true; //Data is loading
    });
    locationName = await getUserLocation();
    _startVideoPlayer();
    print(locationName);
    setState(() {
      loadingLocation = false;
      loadingVideo = false; //Data has loaded
    });
  }

  Future<void> _startVideoPlayer() async {
    if (widget.videoFile == null) {
      print("video file is null");
      return;
    }
    print("initializing videoPlayerController");
    final VideoPlayerController vController =
        VideoPlayerController.file(File(widget.videoFile!.path));
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
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        videoController = vController;
      });
    }
    await vController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, StreamPage.id);
                },
                icon: Icon(Icons.explore)),
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, CameraScreen.id);
                },
                icon: Icon(Icons.add_box_outlined)),
            IconButton(onPressed: () {}, icon: Icon(Icons.video_library_sharp)),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Flyin",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications,
                        size: 25,
                      ))
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                  child: ListView(
                children: [
                  loadingVideo
                      ? Center(child: CircularProgressIndicator())
                      : _thumbnailWidget(),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                      controller: _title,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Title",
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      controller: _description,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Description",
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text("Location "),
                      SizedBox(
                        width: 10,
                      ),
                      loadingLocation
                          ? SizedBox(
                              height: 10,
                              width: 10,
                              child: CircularProgressIndicator())
                          : Expanded(
                              child: Text(
                                '$locationName',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Category"),
                  SizedBox(
                    height: 10,
                  ),
                  Spacer(),
                  // Center(),
                  // child: task != null ? buildUploadStatus(task!) : Container()),
                  Center(
                    child: Material(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: TextButton(
                        onPressed: () async {
                          setState(() {
                            videoUploading = true;
                          });

                          uploadVideo();

                          await Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PostConfirmationScreen()),
                              (route) => false);
                        },
                        child: videoUploading
                            ? CircularProgressIndicator()
                            : Text(
                                "Post Video",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  // void uploadVideo() async {
  //   File file = File(widget.videoFile!.path);
  //
  //   final fileName = basename(file.path);
  //
  //   final destination = 'videos/$fileName';
  //
  //   task = FirebaseApi.uploadFile(destination, file);
  //
  //   if (task == null) return;
  //
  //   final snapshot = await task!.whenComplete(() => videoUploading = false);
  //
  //   final videoUrl = await snapshot.ref.getDownloadURL();
  //
  //   print('Download-Link : $videoUrl');
  //
  //   _firestore.collection('videoinformation').add({
  //     'title': _title.text,
  //     'description': _description.text,
  //     'userName': loggedInUser!.uid,
  //     'location': locationName,
  //     'url': videoUrl,
  //   });
  //
  //   // setState(() {});
  // }

  // Widget buildUploadStatus(UploadTask task) =>
  //     StreamBuilder<TaskSnapshot>(builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         final snap = snapshot.data;
  //         final progress = snap!.bytesTransferred / snap.totalBytes;
  //         final percentage = (progress * 100).toStringAsFixed(2);
  //         print(percentage);
  //         return Text("$percentage % ");
  //       } else
  //         return Container();
  //     });

  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return localVideoController == null
        ? Container()
        : Container(
            child: Center(
              child: Transform.scale(
                scale: 1.98,
                child: Transform.rotate(
                  angle: 3 * (pi / 2),
                  child: AspectRatio(
                      aspectRatio: localVideoController.value.aspectRatio,
                      child: VideoPlayer(localVideoController)),
                ),
              ),
            ),
            height: 200,
            width: double.infinity,
            color: Colors.white,
          );
  }
}

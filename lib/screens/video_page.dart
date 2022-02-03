import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bc_assignment/components/video_search.dart';
import 'stream_page.dart';
import 'camera_screen.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  static const String id = 'video_page';
  final videoUrl;
  final videoTitle;
  final videoDescription;
  VideoPage(
      {required this.videoUrl,
      required this.videoDescription,
      required this.videoTitle});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  final _searchController = TextEditingController();

  @override
  void initState() {
    _controller = VideoPlayerController.network(
      widget.videoUrl,
    );

    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
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
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
                child: ListView(
              children: [
                VideoSearch(searchController: _searchController),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Center(
                    child: Transform.scale(
                      scale: 1.98,
                      child: Transform.rotate(
                        angle: 3 * (pi / 2),
                        child: FutureBuilder(
                          future: _initializeVideoPlayerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.black,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  height: 200,
                  width: double.infinity,
                  color: Colors.white,
                ),
                Container(
                  color: Colors.black,
                  height: 40,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            _controller.play();
                          },
                          icon: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          )),
                      IconButton(
                          onPressed: () {
                            _controller.pause();
                          },
                          icon: Icon(
                            Icons.pause,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.videoTitle}',
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${widget.videoDescription}',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.thumb_up)),
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.thumb_down)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.share)),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("#Views"),
                          Text("#Days ago"),
                          Text("Category"),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text("User name"), Text("View All videos")],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Comments",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                                textAlign: TextAlign.start,
                                onChanged: (value) {},
                                decoration: InputDecoration(
                                    hintText: 'Reply',
                                    hintStyle: TextStyle(
                                        fontSize: 17, color: Colors.grey))),
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.send)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

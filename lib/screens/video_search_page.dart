import 'package:bc_assignment/components/video_stream_template.dart';
import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bc_assignment/components/video_search.dart';

class VideoSearchPage extends StatefulWidget {
  final searchTitle;
  VideoSearchPage({required this.searchTitle});

  @override
  _VideoSearchPageState createState() => _VideoSearchPageState();
}

class _VideoSearchPageState extends State<VideoSearchPage> {
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();

  // void searchVideo() async {
  //   print("search video called");
  //   final videos = await _firestore.collection('videoinformation').get();
  //   for (var video in videos.docs) {
  //     print(video.data());
  //   }
  //   setState(() {});
  // }

  void searchVideoStream() async {
    await for (var snapshot
        in _firestore.collection('videoinformation').snapshots()) {
      for (var videos in snapshot.docs) {
        print(videos.data());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    searchVideoStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.explore)),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(right: 12, left: 12, top: 10),
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
          VideoSearch(
            searchController: _searchController,
          ),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('videoinformation').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final videoInformation = snapshot.data!.docs;
                List<VideoStreamTemplate> videoTiles = [];
                for (var videoInfo in videoInformation) {
                  final videoTitle = videoInfo.get('title');
                  print(videoTitle);
                  print(widget.searchTitle);
                  if (videoTitle == widget.searchTitle) {
                    final number = videoInfo.get('userName');
                    final description = videoInfo.get('description');
                    final location = videoInfo.get('location');
                    final videoUrl = videoInfo.get('url');

                    final videoTile = VideoStreamTemplate(
                      description: description,
                      videoUrl: videoUrl,
                      title: videoTitle,
                      userName: number,
                      location: location,
                    );
                    videoTiles.add(videoTile);
                  }
                }
                return Expanded(
                  child: ListView(
                    reverse: false,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    children: videoTiles,
                  ),
                );
              }),
        ]),
      ),
    );
  }
}

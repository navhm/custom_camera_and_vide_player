import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bc_assignment/components/video_stream_template.dart';
import 'package:bc_assignment/components/video_search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

// import 'package:firebase_auth/firebase_auth.dart';

import 'camera_screen.dart';

class StreamPage extends StatefulWidget {
  static const String id = 'stream_page';

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  final TextEditingController searchText = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final videosReference = FirebaseDatabase.instance.reference().child('videos');
  // DatabaseReference? _videoRef;
  // final _auth = FirebaseAuth.instance;

  void videoStream() async {
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
    videoStream();
    // _videoRef = FirebaseDatabase.instance.reference().child('videos');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 12, top: 10),
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
              searchController: searchText,
            ),
            SizedBox(
              height: 10,
            ),
            // StreamBuilder<QuerySnapshot>(
            //     stream: _firestore.collection('videoinformation').snapshots(),
            //     builder: (context, snapshot) {
            //       if (!snapshot.hasData) {
            //         return Center();
            //       }
            //       final videoInformation = snapshot.data!.docs;
            //       List<VideoStreamTemplate> videoTiles = [];
            //       for (var videoInfo in videoInformation) {
            //         final videoTitle = videoInfo.get('title');
            //         final userName = videoInfo.get('userName');
            //         final videoDescription = videoInfo.get('description');
            //         final location = videoInfo.get('location');
            //         final videoUrl = videoInfo.get('url');
            //
            //         final videoTile = VideoStreamTemplate(
            //           videoUrl: videoUrl,
            //           title: videoTitle,
            //           userName: userName,
            //           location: location,
            //           description: videoDescription,
            //         );
            //         videoTiles.add(videoTile);
            //       }
            //       return Expanded(
            //         child: ListView(
            //           reverse: false,
            //           padding: EdgeInsets.symmetric(vertical: 15),
            //           children: videoTiles,
            //         ),
            //       );
            //     }),
            Flexible(
                child: new FirebaseAnimatedList(
              shrinkWrap: true,
              query: videosReference,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return VideoStreamTemplate(
                    userName: snapshot.value['userName'],
                    videoUrl: snapshot.value['url'],
                    location: snapshot.value['location'],
                    title: snapshot.value['title'],
                    description: snapshot.value['description']);
              },
            ))
          ],
        ),
      ),
    );
  }
}

import 'package:bc_assignment/screens/stream_page.dart';
import 'package:bc_assignment/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'stream_page.dart';

class PostConfirmationScreen extends StatelessWidget {
  static const String id = 'post_confirmation_screen';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
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
                IconButton(
                    onPressed: () {}, icon: Icon(Icons.video_library_sharp)),
              ],
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Flyin",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications,
                            size: 25,
                          ))
                    ],
                  ),
                  Column(
                    children: [
                      Text("Video Poster Successfully"),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StreamPage()),
                              (route) => false);
                        },
                        child: Center(
                          child: Text(
                            "Go to Stream page",
                            style: TextStyle(fontSize: 15, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(),
                ],
              ),
            ),
          )),
    );
  }
}

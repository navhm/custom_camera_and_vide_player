import 'dart:io';
import 'dart:math';
import 'package:bc_assignment/screens/video_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class VideoStreamTemplate extends StatefulWidget {
  final String title;
  final String location;
  final String userName;
  final String videoUrl;
  final String description;

  VideoStreamTemplate(
      {required this.userName,
      required this.videoUrl,
      required this.location,
      required this.title,
      required this.description});

  @override
  _VideoStreamTemplateState createState() => _VideoStreamTemplateState();
}

class _VideoStreamTemplateState extends State<VideoStreamTemplate> {
  String? fileName;
  bool fetchedImage = false;

  Future<dynamic>? getVideoThumbnail() async {
    fileName = await VideoThumbnail.thumbnailFile(
      video: widget.videoUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat
          .WEBP, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 5,
    );
    setState(() {
      fetchedImage = true;
    });

    print("thumbnail is : $fileName");
  }

  @override
  void initState() {
    getVideoThumbnail();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vTitle = widget.title;
    final vUrl = widget.videoUrl;
    final vDescription = widget.description;
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoPage(
                          videoDescription: vDescription,
                          videoTitle: vTitle,
                          videoUrl: vUrl,
                        )));
          },
          child: Container(
            child: fetchedImage
                ? Transform.scale(
                    scale: 1.98,
                    child: Transform.rotate(
                        angle: 3 * (pi / 2),
                        child: Image.file(
                          File(fileName!),
                          fit: BoxFit.contain,
                        )),
                  )
                : Center(
                    child: CircularProgressIndicator(
                    color: CupertinoColors.black,
                    strokeWidth: 1.5,
                  )),
            height: 200,
            width: double.infinity,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 7, right: 7, top: 20, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                radius: 25,
                child: Icon(
                  Icons.person,
                  size: 20,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Text(widget.location),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(widget.userName),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Views"),
                          Spacer(),
                          Text("Date"),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:bc_assignment/screens/video_search_page.dart';
import 'package:flutter/material.dart';

class VideoSearch extends StatelessWidget {
  final searchController;
  VideoSearch({required this.searchController});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 35,
              child: Material(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: searchController,
                            onChanged: (value) {},
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VideoSearchPage(
                                                    searchTitle:
                                                        searchController
                                                            .text)));
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                ),
                                border: InputBorder.none,
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                    fontSize: 17, color: Colors.white))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.filter_alt_rounded,
                color: Colors.black54,
              ))
        ],
      ),
    );
  }
}

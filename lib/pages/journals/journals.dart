import 'package:bridgemetherapist/Utils.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Journals extends StatefulWidget {
  @override
  _JournalState createState() => _JournalState();
}

class _JournalState extends State<Journals> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.border_color),
        label: Text("Add journal"),
      ),
      appBar: AppBar(
        title: Text(
          'journals'.tr(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: TextField(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(color: kColorGreen, width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!, width: 0.5),
                    ),
                    filled: true,
                    fillColor: Colors.grey[250],
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    hintText: 'search_journals'.tr(),
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                  cursorWidth: 1,
                  maxLines: 1,
                ),
              ),
              JournalListItem(
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.journal_details);
                },
                title: "Title 1",
                content: "Content 1",
                date: "June 31 2021 6:30pm",
              ),
              JournalListItem(
                onTap: () {},
                title: "Title 2",
                content: "Content 2",
                date: "June 31 2021 6:30pm",
              ),
              JournalListItem(
                onTap: () {},
                title: "Title 3",
                content: "Content 3",
                date: "June 31 2021 6:30pm",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JournalListItem extends StatelessWidget {
  final void Function() onTap;
  final String title;
  final String content;
  final String date;

  const JournalListItem({
    Key? key,
    required this.onTap,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  // Text(
                  //   Utils().getMaxDisplayContent(content),
                  //   style: TextStyle(
                  //     color: Colors.grey,
                  //     fontSize: 13,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  date,
                  style: TextStyle(
                    color: kColorPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                // Visibility(
                //   visible: true ,
                //   maintainSize: true,
                //   maintainAnimation: true,
                //   maintainState: true,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(
                //       vertical: 2,
                //       horizontal: 7,
                //     ),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(50),
                //       color: kColorPrimary,
                //     ),
                //     child: Text(
                //       "read",
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 10,
                //         fontWeight: FontWeight.w300,
                //       ),
                //     ),
                //   ),
                // )
              ],
            )
          ],
        ),
      ),
    );
  }
}

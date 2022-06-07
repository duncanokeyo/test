import 'dart:io';

import 'package:flutter/material.dart';
import 'package:easy_web_view/easy_web_view.dart';

class ViewQuestionnaireResults extends StatefulWidget {
  String initialUrl;

  ViewQuestionnaireResults({required this.initialUrl});
  @override
  ViewQuestionnaireResultsState createState() =>
      ViewQuestionnaireResultsState();
}

class ViewQuestionnaireResultsState extends State<ViewQuestionnaireResults> {
  static ValueKey key = const ValueKey('key_0');
  var _isLoading = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Screening tool results'),
          // actions: [
          //   // if (_isLoading) ...[
          //   //   const SizedBox(
          //   //       width: 30,
          //   //     height: 30,
          //   //     child: CircularProgressIndicator(),
              
          //   //   ),
          //   // ]
          // ],
        ),
        body: Stack(
          children: [
            Visibility(
              visible: _isLoading,
              child: const Center(
                child: SizedBox(
                    height: 30, width: 30, child: CircularProgressIndicator()),
              ),
            ),

            // const Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   top: 0,
            //   child: SizedBox(
            //     height: 50,
            //     width: 50,
            //     child: CircularProgressIndicator(),
            //   ),
            // ),
            EasyWebView(
              src: widget.initialUrl,
              onLoaded: (_) {
                setState(() {
                  _isLoading = false;
                });
              },
              key: key,
            ),
          ],
        ));
  }
}

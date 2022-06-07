import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class AppBarTitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Icon(
        //   Icons.add,
        //   color: kColorPink,
        // ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Bridge',
                style: TextStyle(
                  color: kColorGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: 'ME',
                style: TextStyle(
                  color: Colors.yellow[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

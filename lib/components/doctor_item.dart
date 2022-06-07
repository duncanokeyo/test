import 'package:bridgemetherapist/model/Therpist.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/constants.dart';
import '../model/doctor.dart';

class PatientItem extends StatelessWidget {
  final Patient patient;
  final void Function() onTap;

  const PatientItem({
    Key? key,
    required this.onTap,
    required this.patient,
  }) : super(key: key);

  getImageAsset() {
    if (patient.gender == "Male") {
      return "assets/images/icon_man.png";
    }
    return "assets/images/icon_doctor_5.png";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 30,
                backgroundImage: imageProvider,
              ),
              imageUrl: patient.avatarUrl,
              errorWidget: (contex, url, error) {
                return CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    getImageAsset(),
                    fit: BoxFit.fill,
                  ),
                );
              },
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          patient.username!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

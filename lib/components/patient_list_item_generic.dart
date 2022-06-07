import 'package:bridgemetherapist/model/Therpist.dart';
import 'package:bridgemetherapist/pages/doctor/doctor_profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../model/doctor.dart';
import 'custom_button.dart';

class PatientListItemGeneric extends StatelessWidget {
  final Patient patient;

  const PatientListItemGeneric({
    Key? key,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: <Widget>[
            
            CachedNetworkImage(
              width: 60,
              height: 60,
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
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    patient.username!,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            CustomButton(
              text: 'details'.tr(),
              textSize: 14,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PatientProfilePage(patient: patient,),
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 5,
              ),
            )
          ],
        ),
      ),
    );
  }
}

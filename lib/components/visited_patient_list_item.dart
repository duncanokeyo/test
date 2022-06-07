import 'package:bridgemetherapist/model/Therpist.dart';
import 'package:bridgemetherapist/pages/doctor/doctor_profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../model/doctor.dart';

class VisitedPatientListItem extends StatelessWidget {
  final Patient patient;

  const VisitedPatientListItem({
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
    return Container(
      width: 140,
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          const BoxShadow(
              color: Color(0x0c000000),
              offset: const Offset(0, 5),
              blurRadius: 5,
              spreadRadius: 0),
          const BoxShadow(
              color: Color(0x0c000000),
              offset: Offset(0, -5),
              blurRadius: 5,
              spreadRadius: 0),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PatientProfilePage(patient: patient)));
        },
        child: Column(
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
            const SizedBox(
              height: 15,
            ),
            Text(
              patient.username!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

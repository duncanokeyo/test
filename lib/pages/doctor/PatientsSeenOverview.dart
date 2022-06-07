import 'package:bridgemetherapist/components/visited_patient_list_item.dart';
import 'package:bridgemetherapist/controller/PatientsSeenController.dart';
import 'package:bridgemetherapist/model/Therpist.dart';
import 'package:bridgemetherapist/pages/home/widgets/section_header_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../routes/routes.dart';

class PatientsSeenOverview extends StatelessWidget {
  PatientsSeenController controller = Get.find<PatientsSeenController>();

  PatientsSeenOverview() {
    //if (controller.isLoading.isFalse && controller.results.isEmpty) {
    // controller.fetch(false);
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (controller.results.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        SectionHeaderWidget(
          title: 'patients_you_have_visited'.tr(),
          onPressed: () =>
              Navigator.of(context).pushNamed(Routes.patients_seen),
        ),
        Container(
          height: 160,
          child: Obx(
            () {
              if (controller.isLoading.isTrue) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (controller.isLoading.isFalse &&
                  controller.error.isNotEmpty) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        controller.fetch(true);
                      },
                      child:
                          Text("Error fetching seen patients tap to refresh"),
                    ),
                  ),
                );
              } else if (controller.isLoading.isFalse &&
                  controller.error.isEmpty &&
                  controller.results.isEmpty) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 160,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        controller.fetch(true);
                      },
                      child: Text("You havent yet seen any patients"),
                    ),
                  ),
                );
              } else {
                List<Patient> patients =
                    controller.results.take(5).toList();
                return Container(
                  height: 160,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(
                      width: 15,
                    ),
                    itemCount: patients.length,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      return VisitedPatientListItem(
                        patient: patients[index],
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

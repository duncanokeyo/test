import 'package:bridgemetherapist/components/patient_list_item_generic.dart';
import 'package:bridgemetherapist/controller/PatientsSeenController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PatientsSeen extends StatelessWidget {
  PatientsSeenController controller = Get.find<PatientsSeenController>();

  PatientsSeen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Obx(
          () {
            if (controller.isLoading.isTrue) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (controller.isLoading.isFalse &&
                controller.error.isNotEmpty) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      controller.fetch(true);
                    },
                    child: Text("Error fetching seen patients tap to refresh"),
                  ),
                ),
              );
            } else if (controller.isLoading.isFalse &&
                controller.error.isEmpty &&
                controller.results.isEmpty) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
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
              return Container(
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => SizedBox(
                    width: 15,
                  ),
                  itemCount: controller.results.length,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    return PatientListItemGeneric(
                      patient: controller.results[index],
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

import 'package:bridgemetherapist/components/patient_list_item_generic.dart';
import 'package:bridgemetherapist/controller/MyPatientsController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../../components/doctor_item.dart';
import '../../../components/round_icon_button.dart';
import '../../../model/doctor.dart';
import '../../../routes/routes.dart';
import '../../../utils/constants.dart';

class MyPatientsListPage extends StatelessWidget {
  MyPatientsController controller = Get.find<MyPatientsController>();

  MyPatientsListPage() {
    controller.fetch(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'my_patients'.tr(),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     onPressed: () {
        //       Navigator.of(context).pushNamed(Routes.filter);
        //     },
        //     icon: Icon(
        //       Icons.filter_list,
        //     ),
        //   )
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
           
            Container(
              child: Obx(() {
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
                          controller.fetch(
                              true);
                        },
                        child: Text("Error fetching patients tap to refresh"),
                      ),
                    ),
                  );
                } else if (controller.isLoading.isFalse &&
                    controller.error.isEmpty &&
                    controller.results.isEmpty) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 100,
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          controller.fetch(true);
                        },
                        child: Text("No Patients"),
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      // Container(
                      //   margin: EdgeInsets.symmetric(
                      //     horizontal: 20,
                      //   ),
                      //   padding: EdgeInsets.all(20),
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(4),
                      //     color: kColorGreen,
                      //   ),
                      //   child: Row(
                      //     children: <Widget>[
                      //       RoundIconButton(
                      //         onPressed: () {},
                      //         icon: Icons.person_pin,
                      //       ),
                      //       SizedBox(
                      //         width: 20,
                      //       ),
                      //       Text(
                      //         'any_available_doctor'.tr(),
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 18,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      ListView.separated(
                        separatorBuilder: (context, index) => Divider(),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.results.length,
                        itemBuilder: (context, index) {
                          return PatientListItemGeneric(
                            patient: controller.results[index],
                          );
                        },
                      ),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

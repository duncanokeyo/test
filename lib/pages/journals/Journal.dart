
import 'package:bridgemetherapist/controller/JournalController.dart';
import 'package:bridgemetherapist/pages/journals/journal_list.dart';
import 'package:bridgemetherapist/routes/routes.dart';
import 'package:bridgemetherapist/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Journal extends StatelessWidget {
  JournalController controller = Get.find<JournalController>();

  Journal() {
    controller.fetch(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kColorDarkGreen,
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.addJournal,
          );
        },
        icon: Icon(Icons.border_color),
        label: Text("Add journal"),
      ),
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            child: Container(
              child: Obx(
                () {
                  if (controller.isLoading.isTrue) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (controller.isLoading.isFalse &&
                      controller.error.isNotEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            controller.fetch(true);
                          },
                          child: Text("Error fetching jounrals. Tap to retry"),
                        ),
                      ),
                    );
                  } else if (controller.isLoading.isFalse &&
                      controller.error.isEmpty &&
                      controller.results.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            controller.fetch(true);
                          },
                          child: Text("You dont have any journals"),
                        ),
                      ),
                    );
                  } else {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text('Journals'),
                      ),
                      body: Column(
                        children: [
                          // Container(
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomIconBtn(
                          //         color: Theme.of(context).backgroundColor,
                          //         onPressed: () {
                          //           //  authController.axisCount.value =
                          //           //    authController.axisCount.value == 2 ? 4 : 2;
                          //         },
                          //         icon: Icon(Icons.list),

                          //       ),
                          //       Text(
                          //         "Journals",
                          //         style: TextStyle(
                          //           fontSize: 24,
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),

                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          JournalList(items: controller.results.toList()),
                        ],
                      ),
                    );
                  }
                },
              ),
            )),
      ),
    );
  }
}

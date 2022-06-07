import 'package:bridgemetherapist/controller/UpcomingSessionsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../components/upcoming_appointment_list_item.dart';

class UpcomingAppointmentsPage extends StatelessWidget {
  UpcomingSessionsController controller =
      Get.find<UpcomingSessionsController>();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  UpcomingAppointmentsPage() {
    if (controller.isLoading.isFalse && controller.results.isEmpty) {
      controller.fetch(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return Padding(
            padding: const EdgeInsets.only(left: 15),
            child: SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text("Today"),
                      selected: controller.todaySelected.value,
                      backgroundColor: Colors.transparent,
                      shape: const StadiumBorder(side: BorderSide()),
                      onSelected: (bool value) {
                        controller.todaySelected.value = value;
                        controller.filter_();
                        print("selected");
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    FilterChip(
                      label: const Text("Paid"),
                      selected: controller.paidSelected.value,
                      backgroundColor: Colors.transparent,
                      shape: const StadiumBorder(side: BorderSide()),
                      onSelected: (bool value) {
                        controller.paidSelected.value = value;
                        controller.filter_();
                        print("selected");
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        
        Obx(() {
          if (controller.isLoading.isTrue) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/2,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (controller.isLoading.isFalse &&
              controller.error.isNotEmpty) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/2,
              child: Center(
                child: InkWell(
                  onTap: () {
                    controller.fetch(true);
                  },
                  child:
                      Text("Error fetching upcoming sessions. Tap to refresh"),
                ),
              ),
            );
          } else if (controller.isLoading.isFalse &&
              controller.error.isEmpty &&
              controller.filter.isEmpty) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/2,
              child: Center(
                child: InkWell(
                  onTap: () {
                    controller.fetch(true);
                  },
                  child: const Text("No upcoming sessions"),
                ),
              ),
            );
          } else {
            return Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: false,
                onRefresh: () {
                  controller.fetch(true);
                  _refreshController.refreshCompleted();
                },
                child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 15,
                  ),
                  itemCount: controller.filter.length,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 15,
                  ),
                  itemBuilder: (context, index) {
                    return UpcomingAppointmentListItem(
                      sessionBookings: controller.filter[index],
                    );
                  },
                ),
              ),
            );
          }
        })
      ],
    );
  }
}

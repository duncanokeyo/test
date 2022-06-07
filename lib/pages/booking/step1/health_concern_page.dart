import 'package:bridgemetherapist/controller/HealthConcernController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart' hide Trans;

import '../../../components/health_concern_item.dart';
import '../../../model/health_category.dart';
import '../../../routes/routes.dart';

class AvailabilityScreen extends StatelessWidget {
  HealthConcernController controller = Get.find<HealthConcernController>();

  AvailabilityScreen() {
    controller.fetch(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'availability'.tr(),
        ),
      ),
      body: Obx(
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
                  child: Text("Error Health concerns tap to refresh"),
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
                  child: Text("No data"),
                ),
              ),
            );
          } else {
            return Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'choose_health_concern'.tr(),
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                        StaggeredGridView.countBuilder(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          crossAxisCount: 4,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.results.length,
                          staggeredTileBuilder: (int index) =>
                              StaggeredTile.fit(2),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          itemBuilder: (context, index) {
                            return HealthConcernItem(
                              concern: controller.results[index],
                              onTap: () {
                                controller.selectedHealthConcern =
                                    controller.results[index];
                                Navigator.of(context)
                                    .pushNamed(Routes.bookingStep2);
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

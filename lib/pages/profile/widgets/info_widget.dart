import 'package:bridgemetherapist/model/Profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'profile_info_tile.dart';
import 'package:get_storage/get_storage.dart';

class InfoWidget extends StatelessWidget {
  final box = Get.find<GetStorage>();

  late Profile profile;

  @override
  Widget build(BuildContext context) {
    profile = profileFromMap(box.read('profile'))[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(
            'name_dot'.tr(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Text(
            profile.username,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          trailing: SizedBox(
            height: 30,
            width: 30,
            child: CachedNetworkImage(
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 30,
                backgroundImage: imageProvider,
              ),
              imageUrl: profile.avatarUrl,
              errorWidget: (contex, url, error) {
                return CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    'assets/images/icon_man.png',
                    fit: BoxFit.fill,
                  ),
                );
              },
            ),
          ),
        ),
        Divider(
          height: 0.5,
          color: Colors.grey[200],
          indent: 15,
          endIndent: 15,
        ),
        ProfileInfoTile(
          title: 'contact_number'.tr(),
          trailing: profile.phoneNumber,
          hint: 'Add phone number',
        ),
        ProfileInfoTile(
          title: 'email'.tr(),
          trailing: profile.email,
          hint: 'add_email'.tr(),
        ),
        ProfileInfoTile(
          title: 'gender'.tr(),
          trailing: profile.gender,
          hint: 'add_gender'.tr(),
        ),
        // ProfileInfoTile(
        //   title: 'date_of_birth'.tr(),
        //   trailing: null,
        //   hint: 'yyyy mm dd',
        // ),
        // ProfileInfoTile(
        //   title: 'blood_group'.tr(),
        //   trailing: 'O+',
        //   hint: 'add_blood_group'.tr(),
        // ),
        // ProfileInfoTile(
        //   title: 'marital_status'.tr(),
        //   trailing: null,
        //   hint: 'add_marital_status'.tr(),
        // ),
        // ProfileInfoTile(
        //   title: 'height'.tr(),
        //   trailing: null,
        //   hint: 'add_height'.tr(),
        // ),
        // ProfileInfoTile(
        //   title: 'weight'.tr(),
        //   trailing: null,
        //   hint: 'add_weight'.tr(),
        // ),
        // ProfileInfoTile(
        //   title: 'emergency_contact'.tr(),
        //   hint: 'add_emergency_contact'.tr(),
        // ),
        // ProfileInfoTile(
        //   title: 'location'.tr(),
        //   hint: 'add_location'.tr(),
        // ),
      ],
    );
  }
}

import 'package:bridgemetherapist/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sup1;

import '../../../components/custom_icons.dart';
import '../../../components/social_icon.dart';

class SocialLoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Divider(
                color: Colors.grey,
                endIndent: 20,
              ),
            ),
            Text(
              'social_login'.tr(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
            const Expanded(
              child: Divider(
                color: Colors.grey,
                indent: 20,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SocialIcon(
              colors: const [
                Color(0xff102397),
                Color(0xff187adf),
              ],
              iconData: CustomIcons.facebook,
              onPressed: () {
                 supabase.auth.signInWithProvider(
                  Provider.facebook,
                  options: sup1.AuthOptions(redirectTo: 'io.supabase.flutterdemo://login-callback'),
                );
              },
            ),
            SocialIcon(
              colors: const [
                Color(0xffff4f38),
                Color(0xff1ff355d),
              ],
              iconData: CustomIcons.googlePlus,
              onPressed: () {
                supabase.auth.signInWithProvider(
                  Provider.github,
                  options: sup1.AuthOptions(redirectTo: 'io.supabase.flutterdemo://login-callback'),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

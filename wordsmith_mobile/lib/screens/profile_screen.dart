import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/profile/profile_image.dart';
import 'package:wordsmith_utils/datetime_formatter.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/size_config.dart';

class ProfileScreenWidget extends StatefulWidget {
  final User user;

  const ProfileScreenWidget({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  String? _getUserProfileImage() {
    if (widget.user.profileImage?.imagePath != null) {
      return widget.user.profileImage!.imagePath;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProfileImageWidget(
                    profileImagePath: _getUserProfileImage(),
                    editCallback:
                        null, // Should be set to a callback that takes a picked image if editing the profile image is allowed
                  ),
                ),
                SizedBox(
                  width: SizeConfig.safeBlockHorizontal * 2.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.username,
                                softWrap: true,
                              ),
                              Text(
                                widget.user.email,
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Member since",
                                style: theme.textTheme.labelSmall,
                              ),
                              Text(formatDateTime(
                                date: widget.user.registrationDate,
                                format: "yMMMMd",
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Placeholder for now
            FilledButton.tonal(
              onPressed: () {},
              child: const Text("Edit profile"),
            ),
          ],
        ),
      ),
    );
  }
}

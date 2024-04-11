import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/profile/edit_about_dialog.dart';
import 'package:wordsmith_mobile/widgets/profile/edit_username_email_dialog.dart';
import 'package:wordsmith_mobile/widgets/profile/profile_image.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/image_helper.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/image/image_insert.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class PersonalProfileScreenWidget extends StatefulWidget {
  final User user;

  const PersonalProfileScreenWidget({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _PersonalProfileScreenWidgetState();
}

class _PersonalProfileScreenWidgetState
    extends State<PersonalProfileScreenWidget> {
  final _logger = LogManager.getLogger("PersonalProfileScreen");

  late AuthProvider _authProvider;
  late UserProvider _userProvider;

  bool _updatingProfileImage = false;

  final _labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 11.0,
  );

  String? _getUserProfileImage() {
    if (widget.user.profileImage?.imagePath != null) {
      return widget.user.profileImage!.imagePath;
    }

    return null;
  }

  Widget _buildUsernameEmailCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Username and email",
                  style: _labelStyle,
                ),
                IconButton(
                  iconSize: 20.0,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _openEditUsernameEmailDialog(),
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
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
    );
  }

  Widget _buildMemberDateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Member since",
              style: _labelStyle,
            ),
            Text(formatDateTime(
              date: widget.user.registrationDate,
              format: "yMMMMd",
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return SizedBox(
      width: double.infinity,
      height: 150.0,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "About me",
                    style: _labelStyle,
                  ),
                  IconButton(
                    iconSize: 20.0,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _openEditAboutDialog(),
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.user.about,
                    softWrap: true,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCards() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ProfileImageWidget(
              profileImagePath: _getUserProfileImage(),
              editCallback: _editProfileImage,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Builder(builder: (context) => _buildUsernameEmailCard()),
                  Builder(builder: (context) => _buildMemberDateCard()),
                ],
              ),
            ),
          ],
        ),
        Builder(builder: (context) => _buildAboutCard()),
      ],
    );
  }

  void _openEditUsernameEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => EditUsernameEmailDialogWidget(
        user: widget.user,
      ),
    );
  }

  void _openEditAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => EditAboutDialogWidget(
        user: widget.user,
      ),
    );
  }

  void _editProfileImage(XFile? image) async {
    if (_updatingProfileImage || image == null) return;
    _toggleUpdatingProfileImage();
    ProgressIndicatorDialog().show(context, text: "Processing...");

    if (!await ImageHelper.verifySize(image)) {
      if (mounted) {
        showErrorDialog(
          context: context,
          content: const Text("Image is too big! A maximum of 5MB is allowed"),
        );
      }
      return;
    }

    ImageInsert? request = await ImageHelper.toImageInsert(image);

    if (request == null) {
      if (mounted) {
        showErrorDialog(
          context: context,
          content:
              const Text("Wrong image format! Allowed types are JPEG and PNG"),
        );
      }
      return;
    }

    _logger.info("Image is good!");
    await _userProvider.updateProfileImage(request).then((result) async {
      _toggleUpdatingProfileImage();
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success<User>(data: final d):
          showSnackbar(
            context: context,
            content: "Sucesfully updated profile image",
          );
          await _authProvider.storeLogin(user: d);
        case Failure<User>(exception: final e):
          showErrorDialog(context: context, content: Text(e.message));
      }
    });
  }

  void _toggleUpdatingProfileImage() {
    setState(() {
      _updatingProfileImage = !_updatingProfileImage;
    });
  }

  @override
  void initState() {
    _authProvider = context.read<AuthProvider>();
    _userProvider = context.read<UserProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Builder(builder: (context) => _buildPersonalInfoCards()),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

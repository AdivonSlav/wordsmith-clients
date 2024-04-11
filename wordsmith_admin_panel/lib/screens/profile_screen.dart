import "package:file_selector/file_selector.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/widgets/profile/edit_about_dialog.dart";
import "package:wordsmith_admin_panel/widgets/profile/edit_username_email_dialog.dart";
import "package:wordsmith_admin_panel/widgets/profile/profile_image.dart";
import "package:wordsmith_utils/dialogs/progress_indicator_dialog.dart";
import "package:wordsmith_utils/dialogs/show_error_dialog.dart";
import "package:wordsmith_utils/formatters/datetime_formatter.dart";
import "package:wordsmith_utils/image_helper.dart";
import "package:wordsmith_utils/models/image/image_insert.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/user/user.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/providers/user_provider.dart";
import "package:wordsmith_utils/show_snackbar.dart";

class ProfileScreenWidget extends StatefulWidget {
  final User user;

  const ProfileScreenWidget({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  late UserProvider _userProvider;
  late AuthProvider _authProvider;

  final _labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12.0,
  );

  Widget _buildUsernameEmailCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Username and email",
                  style: _labelStyle,
                ),
                IconButton(
                  iconSize: 24.0,
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
            const SizedBox(height: 4.0),
            Text(widget.user.username),
            Text(widget.user.email),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return SizedBox(
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
                    iconSize: 24.0,
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
              const SizedBox(height: 4.0),
              Text(widget.user.about),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberSinceCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Member since",
                style: _labelStyle,
              ),
              const SizedBox(height: 4.0),
              Text(
                formatDateTime(
                    date: widget.user.registrationDate, format: "yMMMd"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    var size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        width: size.width * 0.4,
        constraints: const BoxConstraints(maxWidth: 400.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ProfileImageWidget(
              profileImagePath: widget.user.profileImage?.imagePath,
              radius: 92.0,
              editCallback: _editProfileImage,
            ),
            const SizedBox(height: 32.0),
            Builder(builder: (context) => _buildUsernameEmailCard()),
            Builder(builder: (context) => _buildMemberSinceCard()),
            Builder(builder: (context) => _buildAboutCard()),
          ],
        ),
      ),
    );
  }

  void _openEditUsernameEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => EditUsernameEmailDialogWidget(user: widget.user),
    );
  }

  void _openEditAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => EditAboutDialogWidget(user: widget.user),
    );
  }

  void _editProfileImage(XFile? image) async {
    if (image == null) return;
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

    await _userProvider.updateProfileImage(request).then((result) async {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success<User>(data: final d):
          showSnackbar(
            context: context,
            content: "Sucesfully updated profile image",
          );
          await _authProvider.storeLogin(user: d);
        case Failure<User>(exception: final e):
          showSnackbar(
              context: context,
              content: e.message,
              backgroundColor: Colors.red);
      }
    });
  }

  @override
  void initState() {
    _userProvider = context.read<UserProvider>();
    _authProvider = context.read<AuthProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(builder: (context) => _buildProfileInfo()),
      ),
    );
  }
}

import "package:file_selector/file_selector.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/widgets/profile/profile_image.dart";
import "package:wordsmith_admin_panel/widgets/profile/profile_info_field.dart";
import "package:wordsmith_utils/dialogs/show_error_dialog.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/user/user.dart";
import "package:wordsmith_utils/models/user/user_update.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/providers/user_provider.dart";
import "package:wordsmith_utils/size_config.dart";

class ProfileScreenWidget extends StatefulWidget {
  ProfileScreenWidget({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  State<StatefulWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  late UserProvider _userProvider;
  late AuthProvider _authProvider;

  Future _updateProfile() async {
    String newUsername = widget._usernameController.text;
    String newEmail = widget._emailController.text;

    var payload = UserUpdate(
      username: newUsername.isEmpty ? null : newUsername,
      email: newEmail.isEmpty ? null : newEmail,
    );

    await _userProvider.updateLoggeduser(payload).then((result) async {
      switch (result) {
        case Success<User>():
          await _authProvider.storeLogin(user: result.data);
        case Failure<User>():
          showErrorDialog(
              context: context, content: Text(result.exception.toString()));
      }
    });
  }

  // TODO: Pasha this one's for you
  Future _updateProfileImage(XFile file) async {
    // if (!await ImageHelper.verifySize(file)) {
    //   if (context.mounted) {
    //     await showErrorDialog(
    //       context,
    //       const Text("Error"),
    //       const Text("The maximum image size allowed is 5MB"),
    //     );

    //     return;
    //   }
    // }

    //var imageInsert = await ImageHelper.toImageInsert(file);
    //var payload = UserUpdate(profileImage: imageInsert);

    // if (context.mounted) {
    //   await showErrorDialog(
    //       context, const Text("Error"), const Text("Not implemented yet"));
    // }

    // TODO: Ensure that the image can be updated through an API call
  }

  @override
  Widget build(BuildContext context) {
    if (AuthProvider.loggedUser == null) return const Placeholder();

    _userProvider = Provider.of<UserProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ProfileImageWidget(
              profileImagePath:
                  AuthProvider.loggedUser!.profileImage?.imagePath,
              callbackFunction: _updateProfileImage,
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 3.0),
            ProfileInfoFieldWidget(
              labelText: "Username",
              valueText: AuthProvider.loggedUser!.username,
              controller: widget._usernameController,
              callbackFunction: _updateProfile,
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 1.5),
            ProfileInfoFieldWidget(
              labelText: "Email",
              valueText: AuthProvider.loggedUser!.email,
              controller: widget._emailController,
              callbackFunction: _updateProfile,
            )
          ],
        ),
      ),
    );
  }
}

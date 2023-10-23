import "package:file_selector/file_selector.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/widgets/profile_image.dart";
import "package:wordsmith_admin_panel/widgets/profile_info_field.dart";
import "package:wordsmith_utils/dialogs.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/image_helper.dart";
import "package:wordsmith_utils/models/user_update.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";
import "package:wordsmith_utils/providers/user_provider.dart";

class ProfileScreenWidget extends StatefulWidget {
  ProfileScreenWidget({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  State<StatefulWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  late UserProvider _userProvider;
  late UserLoginProvider _userLoginProvider;

  Future _updateUsername() async {
    String newUsername = widget._usernameController.text;
    var payload = UserUpdate(username: newUsername);
    var bearerToken = await _userLoginProvider.getAccessToken(context);

    if (bearerToken == null) return;

    try {
      var result = await _userProvider.put(
          additionalEndpoint: "/profile",
          request: payload,
          bearerToken: bearerToken);

      await _userLoginProvider.storeLogin(user: result);
    } on BaseException catch (error) {
      if (context.mounted) {
        await showErrorDialog(
            context, const Text("Error"), Text(error.message));
      }
    }
  }

  Future _updateEmail() async {}

  Future _updateProfileImage(XFile file) async {
    var bearerToken = await _userLoginProvider.getAccessToken(context);

    if (bearerToken == null) return null;

    if (!await ImageHelper.verifySize(file)) {
      if (context.mounted) {
        await showErrorDialog(
          context,
          const Text("Error"),
          const Text("The maximum image size allowed is 5MB"),
        );

        return;
      }
    }

    var imageInsert = await ImageHelper.toImageInsert(file);
    var payload = UserUpdate(profileImage: imageInsert);

    if (context.mounted) {
      await showErrorDialog(
          context, const Text("Error"), Text("Not implemented yet"));
    }

    // TODO: Ensure that the image can be updated through an API call

    /*
    try {
      var result = await _userProvider.put(
          additionalEndpoint: "/profile",
          request: payload,
          bearerToken: bearerToken);

      await _userLoginProvider.storeLogin(user: result);
    } on BaseException catch (error) {
      if (context.mounted) {
        await showErrorDialog(
            context, const Text("Error"), Text(error.message));
      }
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    if (UserLoginProvider.loggedUser == null) return const Placeholder();

    _userProvider = context.read<UserProvider>();
    _userLoginProvider = context.read<UserLoginProvider>();

    print(UserLoginProvider.loggedUser!.profileImage);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ProfileImageWidget(
              profileImagePath:
                  UserLoginProvider.loggedUser!.profileImage?.imagePath,
              callbackFunction: _updateProfileImage,
            ),
            const SizedBox(height: 32.0),
            ProfileInfoFieldWidget(
              labelText: "Username",
              valueText: UserLoginProvider.loggedUser!.username,
              controller: widget._usernameController,
              callbackFunction: _updateUsername,
            ),
            const SizedBox(height: 16.0),
            ProfileInfoFieldWidget(
              labelText: "Email",
              valueText: UserLoginProvider.loggedUser!.email,
              controller: widget._emailController,
              callbackFunction: _updateEmail,
            )
          ],
        ),
      ),
    );
  }
}

import "package:file_selector/file_selector.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/widgets/profile_image.dart";
import "package:wordsmith_admin_panel/widgets/profile_info_field.dart";
import "package:wordsmith_utils/dialogs.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/image_helper.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/user_update.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";
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
  final Logger _logger = LogManager.getLogger("ProfileScreen");
  late UserProvider _userProvider;
  late UserLoginProvider _userLoginProvider;

  Future _updateProfile() async {
    String newUsername = widget._usernameController.text;
    String newEmail = widget._emailController.text;

    var payload = UserUpdate(
      username: newUsername.isEmpty ? null : newUsername,
      email: newEmail.isEmpty ? null : newEmail,
    );
    var bearerToken = await _userLoginProvider.getAccessToken(context);

    if (bearerToken == null) return;

    try {
      var result = await _userProvider.put(
          additionalRoute: "/profile",
          request: payload,
          bearerToken: bearerToken);

      await _userLoginProvider.storeLogin(user: result);
    } on BaseException catch (error) {
      if (context.mounted) {
        await showErrorDialog(
            context, const Text("Error"), Text(error.message));
      }
    } on Exception catch (error) {
      if (context.mounted) {
        await showErrorDialog(
            context, const Text("Error"), Text(error.toString()));
      }

      _logger.severe(error);
    }
  }

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

    //var imageInsert = await ImageHelper.toImageInsert(file);
    //var payload = UserUpdate(profileImage: imageInsert);

    if (context.mounted) {
      await showErrorDialog(
          context, const Text("Error"), const Text("Not implemented yet"));
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
            SizedBox(height: SizeConfig.safeBlockVertical * 3.0),
            ProfileInfoFieldWidget(
              labelText: "Username",
              valueText: UserLoginProvider.loggedUser!.username,
              controller: widget._usernameController,
              callbackFunction: _updateProfile,
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 1.5),
            ProfileInfoFieldWidget(
              labelText: "Email",
              valueText: UserLoginProvider.loggedUser!.email,
              controller: widget._emailController,
              callbackFunction: _updateProfile,
            )
          ],
        ),
      ),
    );
  }
}

# Wordsmith Clients
Client desktop and mobile applications for Wordsmith written in Flutter for a university project. Mobile app supports Android and iOS, while the desktop client application supports Windows and Linux.

The mobile application allows users to browse ebooks posted by the app community, synchronize them with their library and read them with a built-in EPUB reader. Authors can post their ebooks on the app and optionally monetize them.

The desktop side is meant for admins and it allows them to perform tasks such as moderation, user management, report generation and so on.

## Getting Started

### Prerequisites

Before either clients can be used, the [common API backend](https://github.com/AdivonSlav/wordsmith-api) must be setup. 

Currently no binaries are provided, so the project must be compiled and used from source. To start, Flutter must be installed and configured for your system as per the [official docs](https://docs.flutter.dev/get-started/install).

Additonally, if on Linux, the following dependencies must be installed. An example for Ubuntu systems is:
```bash
apt install libsecret-1-dev libjsoncpp-dev libsecret-1-0 libjsoncpp25
```

### Credentials

For test purposes, the API backend provides some test accounts for the client applications.

```bash
# Admin account
Username: orwell47
Password: default$123
PayPal email: orwell47@personal.com
PayPal password: default$123

# Normal user account
Username: john_doe1
Password: default$123
PayPal email: john_doe1@personal.com
PayPal password: default$123

# Seller user acount (will have published books)
Username: jane_doe2
Password: default$123
PayPal email: jane_doe2@personal.com
PayPal password: default$123
```

### Setup

Clone the repository
```bash
git clone https://github.com/AdivonSlav/wordsmith-clients
```

Install all required dependencies
```bash
flutter pub get -C wordsmith_utils
flutter pub get -C wordsmith_admin_panel
flutter pub get -C wordsmith_mobile
```

Check out the .example.env file for both the mobile and desktop client. Make the necessary changes and rename it to .env (otherwise the app will crash on startup)

To run a client, change into the respective directory (admin_panel or mobile) and run the following
```bash
flutter run # Debug mode
flutter run --release # Release mode
```

For the mobile client, you obviously must have a physical device connected or a VM up and running.

## License

This project is licensed under Apache 2.0. For more information, read the [LICENSE](LICENSE) file. In short, do whatever you want as this is a university project.







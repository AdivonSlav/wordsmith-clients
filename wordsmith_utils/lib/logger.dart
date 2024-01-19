// ignore_for_file: constant_identifier_names, avoid_print

import "package:logging/logging.dart";

enum LogLevel { OFF, SEVERE, WARNING, INFO }

abstract class LogManager {
  static void init(LogLevel rootLevel) {
    Logger.root.level = _getLevel(rootLevel);
    Logger.root.onRecord.listen((record) {
      print(
          "${record.time} ${record.loggerName} ${record.level.name}: ${record.message}");
    });
  }

  static Logger getLogger(String className) {
    return Logger(className);
  }

  static Level _getLevel(LogLevel level) {
    switch (level) {
      case LogLevel.OFF:
        return Level.OFF;
      case LogLevel.SEVERE:
        return Level.SEVERE;
      case LogLevel.WARNING:
        return Level.WARNING;
      case LogLevel.INFO:
        return Level.INFO;
      default:
        return Level.OFF;
    }
  }
}

import 'dart:developer' as developer;

/// Logger utility for consistent logging across the application
class Logger {
  static const String _appName = 'GuardTrack';
  
  /// Log debug information
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('DEBUG', message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log informational messages
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('INFO', message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('WARNING', message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Internal logging method
  static void _log(
    String level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final logMessage = '$_appName $level: $tagPrefix$message';
    
    developer.log(
      logMessage,
      name: _appName,
      error: error,
      stackTrace: stackTrace,
      level: _getLevelValue(level),
    );
  }
  
  /// Get numeric level value for developer.log
  static int _getLevelValue(String level) {
    switch (level) {
      case 'DEBUG':
        return 500;
      case 'INFO':
        return 800;
      case 'WARNING':
        return 900;
      case 'ERROR':
        return 1000;
      default:
        return 800;
    }
  }
}

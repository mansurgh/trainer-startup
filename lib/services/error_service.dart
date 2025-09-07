import 'package:flutter/material.dart';

class AppError {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppError: $message (code: $code)';
}

class ErrorService {
  static void showErrorSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Закрыть',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static AppError handleException(dynamic exception, [StackTrace? stackTrace]) {
    if (exception is AppError) {
      return exception;
    }

    // Handle specific exception types
    if (exception.toString().contains('SocketException')) {
      return const AppError(
        message: 'Нет подключения к интернету. Проверьте соединение.',
        code: 'NO_INTERNET',
      );
    }

    if (exception.toString().contains('TimeoutException')) {
      return const AppError(
        message: 'Превышено время ожидания. Попробуйте снова.',
        code: 'TIMEOUT',
      );
    }

    if (exception.toString().contains('FormatException')) {
      return const AppError(
        message: 'Ошибка формата данных. Попробуйте снова.',
        code: 'FORMAT_ERROR',
      );
    }

    if (exception.toString().contains('Permission denied')) {
      return const AppError(
        message: 'Недостаточно прав доступа. Проверьте настройки.',
        code: 'PERMISSION_DENIED',
      );
    }

    if (exception.toString().contains('File not found')) {
      return const AppError(
        message: 'Файл не найден. Попробуйте выбрать другой файл.',
        code: 'FILE_NOT_FOUND',
      );
    }

    // Generic error
    return AppError(
      message: 'Произошла неизвестная ошибка. Попробуйте снова.',
      code: 'UNKNOWN',
      originalError: exception,
      stackTrace: stackTrace,
    );
  }

  static void logError(AppError error) {
    // In a real app, you would log to a service like Crashlytics
    debugPrint('Error: ${error.message}');
    debugPrint('Code: ${error.code}');
    if (error.originalError != null) {
      debugPrint('Original error: ${error.originalError}');
    }
    if (error.stackTrace != null) {
      debugPrint('Stack trace: ${error.stackTrace}');
    }
  }
}

// Extension for easy error handling
extension ErrorHandling<T> on Future<T> {
  Future<T?> handleError(BuildContext context) async {
    try {
      return await this;
    } catch (e, stackTrace) {
      final error = ErrorService.handleException(e, stackTrace);
      ErrorService.logError(error);
      ErrorService.showErrorSnackBar(context, error);
      return null;
    }
  }
}

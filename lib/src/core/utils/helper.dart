import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Helper {
  static GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static getImagesPath(String image) {
    return 'assets/images/$image';
  }

  static String? convertRemoteErrorMessage(DioException error) {
    String? errorMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timed out. Please try again.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request timed out. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Server response timed out. Please check your connection.';
        break;
      case DioExceptionType.badResponse:
        if (error.response == null) {
          errorMessage = 'No response received from the server. Please try again.'; //noResponseReceivedFromServerPleaseTryAgain
        } else {
          if (error.response?.statusCode == 404) {
            errorMessage = 'Resource not found. Please try again.';
            return errorMessage;
          }
          if (error.response?.data is String) {
            errorMessage = error.response?.data.toString();
          } else if (error.response?.data is Map<String, dynamic>) {
            errorMessage = error.response?.data['message'] ??
                error.response?.data['error'] ?? error.response?.data['detail'];
          } else {
            errorMessage = 'Some thing went wrong. Please try again.';
          }
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled. Please try again.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'An unknown error occurred. Please try again.';
        break;
      default:
        if (error.error is SocketException) {
          errorMessage = 'No internet connection. Please check your network.';
        } else {
          errorMessage = 'Some thing went wrong. Please try again.';
        }
    }
    return errorMessage;
  }
}

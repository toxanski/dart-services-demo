import 'package:auth/models/app_response_model.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppResponse extends Response {
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResponseModel(error, message));

  static AppResponseModel _getResponseModel(error, String? message) {
    if (error is QueryException) {
      return AppResponseModel(
          error: error.toString(), message: message ?? error.message);
    }

    if (error is JwtException) {
      return AppResponseModel(
          error: error.toString(), message: message ?? error.message);
    }

    return AppResponseModel(
        error: error.toString(), message: message ?? "Undefined error");
  }

  AppResponse.ok({dynamic body, String? message})
      : super.ok(AppResponseModel(data: body, message: message));
}

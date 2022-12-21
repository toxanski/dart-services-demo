import 'dart:io';

import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  // приводит к невозможности создания
  // instance от абстрактного класса
  const AppUtils._();

  static int getIdFromToken(String token) {
    try {
      final secretKey = Platform.environment["SECRET_KEY"];
      final JwtClaim jwtClaim =
          verifyJwtHS256Signature(token, secretKey ?? "SECRET_KEY");

      return int.parse(jwtClaim["id"].toString());
    } catch (_) {
      rethrow;
    }
  }
}

import 'dart:io';

import 'package:auth/models/app_response_model.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../models/user.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.username == null) {
      return Response.badRequest(
          body: AppResponseModel(
              message: "Поля 'password'/'username' являются обязательными"));
    }

    try {
      final findUserQuery = Query<User>(managedContext)
        ..where((table) => table.username).equalTo(user.username)
        // необходимо вернуть только id, salt и hashPassword
        ..returningProperties(
            (table) => [table.id, table.salt, table.hashPassword]);

      final findUser = await findUserQuery.fetchOne();

      if (findUser == null) {
        throw QueryException.input('Пользователь не найден', []);
      }

      final hashPasswordFromRequest =
          generatePasswordHash(user.password ?? "", findUser.salt ?? "");

      if (hashPasswordFromRequest == findUser.hashPassword) {
        await _updateTokens(findUser.id ?? -1, managedContext);

        final fetchedUser =
            await managedContext.fetchObjectWithID<User>(findUser.id);

        return Response.ok(
            AppResponseModel(data: fetchedUser?.backing.contents));
      } else {
        throw QueryException.input('Неверный пароль', []);
      }
    } on QueryException catch (error) {
      return Response.serverError(
          body: AppResponseModel(message: error.message));
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.username == null || user.email == null) {
      return Response.badRequest(
          body: AppResponseModel(
              message:
                  "Поля 'password'/'username'/'email' являются обязательными"));
    }

    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password ?? "", salt);

    try {
      late final int userId;

      // транзакция; в рамках одной транзакции производится 2 запроса,
      // если они прошли успешно => текущая транзакция будет записана в БД
      await managedContext.transaction((transaction) async {
        final createUserQuery = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;

        final createdUser = await createUserQuery.insert();
        userId = createdUser.asMap()["id"];

        await _updateTokens(userId, transaction);
      });

      final userData = await managedContext.fetchObjectWithID<User>(userId);

      // Если не понятны некоторые момент, то прологировать
      // Например, userData?.backing.contents

      return Response.ok(AppResponseModel(
          data: userData?.backing.contents, message: "Успешная регистрация!"));
    } on QueryException catch (error) {
      return Response.serverError(
          body: AppResponseModel(message: error.message));
    }
  }

  // Перезапись access/refresh токенов в бд
  Future<void> _updateTokens(int userId, ManagedContext transaction) async {
    final Map<String, dynamic> tokens = _getTokens(userId);

    final updateTokensQuery = Query<User>(transaction)
      ..where((user) => user.id).equalTo(userId)
      ..values.accessToken = tokens["access"]
      ..values.refreshToken = tokens["refresh"];

    await updateTokensQuery.updateOne();
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(
      @Bind.path("refresh") String refreshToken) async {
    try {
      final int id = AppUtils.getIdFromToken(refreshToken);
      final user = await managedContext.fetchObjectWithID<User>(id);

      print(user?.refreshToken);
      print(refreshToken);

      if (user?.refreshToken != refreshToken) {
        return Response.unauthorized(
            body: AppResponseModel(message: "He валидный refresh-токен"));
      } else {
        await _updateTokens(id, managedContext);

        final user = await managedContext.fetchObjectWithID<User>(id);

        return Response.ok(AppResponseModel(
            data: user?.backing.contents,
            message: "Успешное обновление токенов доступа"));
      }
    } catch (error) {
      return Response.serverError(
          body: AppResponseModel(message: error.toString()));
    }
  }

  Map<String, dynamic> _getTokens(int userId) {
    // TODO: remove when release
    final key = Platform.environment["SECRET_KEY"] ?? "SECRET_KEY";
    final accessClaimSet =
        JwtClaim(maxAge: Duration(hours: 1), otherClaims: {"id": userId});
    final refreshClaimSet = JwtClaim(otherClaims: {"id": userId});
    final tokens = <String, dynamic>{};

    tokens["access"] = issueJwtHS256(accessClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);

    return tokens;
  }
}

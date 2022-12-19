import 'dart:io';

import 'package:auth/models/app_response_model.dart';
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

    // connect to DB
    // find user
    // check password
    // fetch user

    final User fetchedUser = User();

    return Response.ok(AppResponseModel(data: {
      "id": fetchedUser.id,
      "refreshToken": fetchedUser.refreshToken,
      "accessToken": fetchedUser.accessToken,
    }, message: "Успешная авторизация!")
        .toJson());
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
        final Map<String, dynamic> tokens = _getTokens(userId);

        final updateTokensQuery = Query<User>(transaction)
          ..where((user) => user.id).equalTo(userId)
          ..values.accessToken = tokens["access"]
          ..values.refreshToken = tokens["refresh"];

        await updateTokensQuery.updateOne();
      });

      final userData = await managedContext.fetchObjectWithID<User>(userId);

      return Response.ok(AppResponseModel(
        data: userData?.backing.contents,
        message: "Успешная регистрация!"
      ));

    } on QueryException catch (error) {
      return Response.serverError(
          body: AppResponseModel(message: error.message));
    }
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(
      @Bind.path("refresh") String refreshToken) async {
    // connect to DB
    // find user by token
    // check token
    // fetch user

    final User fetchedUser = User();

    return Response.ok(AppResponseModel(data: {
      "id": fetchedUser.id,
      "refreshToken": fetchedUser.refreshToken,
      "accessToken": fetchedUser.accessToken,
    }, message: "Успешная замена токена доступа!")
        .toJson());
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

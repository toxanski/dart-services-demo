import 'package:auth/models/app_response_model.dart';
import 'package:conduit/conduit.dart';

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

    // connect to DB
    // create user
    // fetch user

    final User fetchedUser = User();

    return Response.ok(AppResponseModel(data: {
      "id": fetchedUser.id,
      "refreshToken": fetchedUser.refreshToken,
      "accessToken": fetchedUser.accessToken,
    }, message: "Успешная авторизация!")
        .toJson());
  }

  @Operation.post("refresh")
  Future<Response> refreshToken(@Bind.path("refresh") String refreshToken) async {

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
}

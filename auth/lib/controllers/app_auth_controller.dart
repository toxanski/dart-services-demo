import 'package:auth/models/app_response_model.dart';
import 'package:conduit/conduit.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);

  @Operation.post()
  Future<Response> signIn() async {
    return Response.ok(AppResponseModel(data: {
      "id": "1",
      "refreshToken": "refreshToken12345",
      "accessToken": "accessToken12345",
    }, message: "signin ok")
        .toJson());
  }

  @Operation.put()
  Future<Response> signUp() async {
    return Response.ok(AppResponseModel(data: {
      "id": "2",
      "refreshToken": "12345refreshToken",
      "accessToken": "12345accessToken",
    }, message: "signup ok")
        .toJson());
  }

  @Operation.post("refresh")
  Future<Response> refreshToken() async {
    return Response.unauthorized(
        body: AppResponseModel(error: "token is not valid").toJson());
  }
}

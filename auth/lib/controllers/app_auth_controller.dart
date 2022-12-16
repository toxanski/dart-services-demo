import 'package:conduit/conduit.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);

  @Operation.post()
  Future<Response> signIn() async {
    return Response.ok("sign in OK");
  }

  @Operation.put()
  Future<Response> signUp() async {
    return Response.ok("sign up OK");
  }

  @Operation.post("refresh")
  Future<Response> refreshToken() async {
    return Response.unauthorized(body: "token is not valid");
  }
}

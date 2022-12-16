import 'package:conduit/conduit.dart';

// ManagedObject => сопоставляется с таблицей в бд
class User extends ManagedObject<_User> implements _User {}

class _User {
  @primaryKey
  int? id;

  @Column(unique: true, indexed: true)
  String? username;

  @Column(unique: true, indexed: true)
  String? email;

  String? password;

  @Column(nullable: true)
  String? accessToken;

  @Column(nullable: true)
  String? refreshToken;
}

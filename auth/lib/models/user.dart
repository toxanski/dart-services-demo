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

  // в body запроса получил, но в бд не пишем
  @Serialize(input: true, output: false)
  String? password;

  @Column(nullable: true)
  String? accessToken;

  @Column(nullable: true)
  String? refreshToken;

  // omitByDefault записать в бд, но при req не возвращать
  @Column(omitByDefault: true)
  String? salt;

  @Column(omitByDefault: true)
  String? hashPassword;
}

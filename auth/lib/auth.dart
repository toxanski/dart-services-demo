import 'dart:io';

import 'package:conduit/conduit.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  PostgreSQLPersistentStore _initDB() {
    final username = Platform.environment["DB_USERNAME"] ?? "admin";
    final password = Platform.environment["DB_PASSWORD"] ?? "root";
    final host = Platform.environment["DB_HOST"] ?? "127.0.0.1";
    final port = int.parse(Platform.environment["DB_PORT"] ?? "5432");
    final databaseName = Platform.environment["DB_NAME"] ?? "postgres";

    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }

  @override
  Future prepare() {
    final persistentStore = _initDB();

    managedContext = ManagedContext(
        // Объявление для контекста => все DataModel, кот. impl ManagedObject
        // будут сопостовляться с таблицами в бд
        ManagedDataModel.fromCurrentMirrorSystem(),
        persistentStore);

    return super.prepare();
  }

  @override
  Controller get entryPoint => Router();
}

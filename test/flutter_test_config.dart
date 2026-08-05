import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter_test/flutter_test.dart';

import 'helpers/firebase_test_helper.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseMocks();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await testMain();
}

import 'package:first_flutter_project/module/storage/device_storage.dart';

Future<bool> checkIsLogin() async {
  final value = await DeviceStorage.loadValue('isLogin');
  return value == 'true';
}

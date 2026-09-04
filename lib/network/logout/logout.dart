
import 'package:first_flutter_project/main.dart';
import 'package:first_flutter_project/module/storage/device_storage.dart';
import 'package:first_flutter_project/pages/splash/splash_screen.dart';


class Logout {

  void logout () async {
    DeviceStorage.setKey('isLogin');
    await DeviceStorage.deleteValue();

    DeviceStorage.setKey('user_info');
    await DeviceStorage.deleteValue();

    // secure_access_token
    DeviceStorage.setKey('secure_access_token');
    await DeviceStorage.deleteValue();

    isSplashScreen.value = true;
    showGetStartedButton = true;
  }
}
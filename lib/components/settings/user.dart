import 'dart:convert';

import 'package:first_flutter_project/module/storage/device_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

/*Holds the data of the user*/
class AuthUser {
  static String username = '';
  static String userEmail = '';
  static String userFullName = '';
  static String isEmailVerify = '';
  static String createdAt = '';
  static String updatedAt = '';

   void response (String responseData) {
    Map<String, dynamic> parseData = jsonDecode(responseData);

    username = parseData['username'];
    userEmail = parseData['email'];
    userFullName = parseData['full_name'];
    isEmailVerify = parseData['is_verified'];
    createdAt = parseData['created_at'];
    updatedAt = parseData['updated_at'];

    try {
      DeviceStorage.setKey('user_info');
      DeviceStorage.saveValue(parseData.toString());
    }
    catch (e) {
      debugPrint('$e');
    }
  }

  void reAssign () {
     DeviceStorage.setKey('user_info');
     String data = DeviceStorage.loadValue('user_info') as String;

    Map<String, dynamic> parseData = jsonDecode(data);

    username = parseData['username'];
    userEmail = parseData['email'];
    userFullName = parseData['full_name'];
    isEmailVerify = parseData['is_verified'];
    createdAt = parseData['created_at'];
    updatedAt = parseData['updated_at'];

  }

}
import 'dart:convert';
import 'dart:io';

import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ecom_delivery_flutter/app/api_providers/customExceptions.dart';

class APIManager {


  Future<dynamic> postAPICallWithHeader(
      String url, var param, Map<String, String> headerData) async {
    print("Calling API: $url");
    print("Calling parameters: $param");
    //headerData["remark"] = "Agent";

    print("Calling header: $headerData");

    var responseJson;
    try {
      final response =
          await http.post(Uri.parse(url), body: param, headers: headerData);
      responseJson = _response(response);
      print("response from api manager $responseJson");
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e) {
      print("all error is $e");
    }
    return responseJson;
  }

  Future<dynamic> postAPICallHeader(
      String url, Map<String, String> headerData) async {
    print("Calling API: $url");
    headerData["remark"] = "Agent";
    print("Calling header: $headerData");

    var responseJson;
    try {
      final response = await http.post(Uri.parse(url), headers: headerData);
      print("$response");
      responseJson = _response(response);
      print(responseJson);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> postAPICallWithOutHeader(String url) async {
    print("Calling API: $url");
    Map<String, String> headerData = {};
    headerData["remark"] = "Agent";
    print("Calling header: $headerData");
    var responseJson;
    try {
      final response = await http.post(Uri.parse(url), headers: headerData);
      responseJson = _response(response);
      print(responseJson);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> postAPICall(String url, Map param) async {
    print("Calling API: $url");
    print("Calling parameters: $param");
    Map<String, String> headerData = {};
    headerData["token"] = Get.find<AuthService>().currentUser.value.data!.token!;
    print("Calling header: $headerData");
    var responseJson;
    try {
      final response =
          await http.post(Uri.parse(url), body: param, headers: headerData);
      responseJson = _response(response);
      print(responseJson);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> loginAPICall(String url, Map param) async {
    print("Calling API: $url");
    print("Calling parameters: $param");
    Map<String, String> headerData = {};
    headerData["token"] = "prefix_67e12b036e3f06.63889147";
    print("Calling header: $headerData");
    var responseJson;
    try {
      final response =
          await http.post(Uri.parse(url), body: param, headers: headerData);
      responseJson = _response(response);
      print(responseJson);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> multipartPostAPI(String url, Map<String, String> param,
      List images, String imageName, Map<String, String> headerData) async {
    print("Calling API: $url");
    print("Calling parameters: $param");
    headerData["remark"] = "Agent";
    print("Calling header: $headerData");
    print(images);

    var responseJson;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(param);

      print('fgdf');

      if (images.isNotEmpty) {
        for (var item in images) {
          String fileName = item.path.split("/").last;
          var stream = http.ByteStream(item.openRead());

          stream.cast();

          print(stream);
          // get file length

          var length = await item.length(); //imageFile is your image file

          // multipart that takes file
          var multipartFileSign =
              http.MultipartFile(imageName, stream, length, filename: fileName);

          request.files.add(multipartFileSign);
        }
      }
      request.headers.addAll(headerData);
      print('fngdfkngdf');
      http.StreamedResponse streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      print(response.statusCode);
      responseJson = _response(response);
      print(responseJson);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> postAPICallWithEncoded(
      String url, Map param, Map<String, String> headerData) async {
    print("Calling API: $url");
    print("Calling parameters: $param");
    headerData["remark"] = "Merchant";
    print("Calling header: $headerData");

    var responseJson;
    try {
      final response = await http.post(Uri.parse(url),
          body: jsonEncode(param), headers: headerData);
      print(response);
      responseJson = _response(response);
      print(responseJson);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> get(String url) async {
    print("Calling API: $url");
    Map<String, String> headerData = {};
    headerData["token"] = Get.find<AuthService>().currentUser.value.data!.token!;
    print("Calling header: $headerData");
    var responseJson;
    try {
      final response = await http.get(Uri.parse(url), headers: headerData);
      print(response.body);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> getWithHeader(
      String url, Map<String, String> headerData) async {
    print("Calling API: $url");
    headerData["Authorization"] = "Bearer ${Get.find<AuthService>().currentUser.value.data!.token}";
    print('token: $headerData');
    var responseJson;
    try {
      final response = await http.get(Uri.parse(url), headers: headerData);
      print(response.body);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<Map<String, dynamic>> getWithHeaderStatus(
      String url, Map<String, String> headerData) async {
    print("Calling API: $url");
    headerData["Authorization"] =
        "Bearer ${Get.find<AuthService>().currentUser.value.data!.token}";
    headerData["Accept"] = "application/json";
    print('token: $headerData');

    try {
      final response = await http.get(Uri.parse(url), headers: headerData);
      final body = _decodeResponseBody(response.body);

      return {
        'status_code': response.statusCode,
        'body': body,
      };
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<Map<String, dynamic>> postJsonWithHeaderStatus(
      String url, Map<String, dynamic> param, Map<String, String> headerData) async {
    print("Calling API: $url");
    print("Calling parameters: $param");
    headerData["Authorization"] =
        "Bearer ${Get.find<AuthService>().currentUser.value.data!.token}";
    headerData["Content-Type"] = "application/json";
    headerData["Accept"] = "application/json";
    print('token: $headerData');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(param),
        headers: headerData,
      );
      final body = _decodeResponseBody(response.body);

      return {
        'status_code': response.statusCode,
        'body': body,
      };
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  dynamic _decodeResponseBody(String body) {
    if (body.isEmpty) return null;

    try {
      return json.decode(body);
    } catch (_) {
      return {'message': body};
    }
  }
 Future<dynamic> patchWithHeader(
      String url, Map<String, String> headerData) async {
    print("Calling API: $url");
    headerData["Authorization"] = "Bearer ${Get.find<AuthService>().currentUser.value.data!.token}";
    print('token: $headerData');
    var responseJson;
    try {
      final response = await http.patch(Uri.parse(url), headers: headerData);
      print(response.body);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _response(http.Response response) {
    print(response);
    print(response.statusCode);
    switch (response.statusCode) {
        case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
        case 201:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
        case 450:
        var responseJson = json.decode(response.body.toString());
        return responseJson;

        case 422:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
        case 400:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 401:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
        case 404:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 403:
      var responseJson = json.decode(response.body.toString());
      return responseJson;
      case 500:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      default:
        throw FetchDataException(
            'Error occurred while communicating with Server with StatusCode: ${response.statusCode}');
    }
  }
}

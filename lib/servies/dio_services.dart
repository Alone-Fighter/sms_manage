import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio_service;
import 'package:shared_preferences/shared_preferences.dart';

class DioSevice {
  Dio dio = Dio();

  Future<dynamic> method(
      String method, String url, Map<String, dynamic> map) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.reload();
    dio.options.headers['content-Type'] = 'application/json';
    Map<String, dynamic> mapData = {};
    String token = sp.getString('token') ?? '';
    if (sp.getString('date') != null && sp.getString('date') != '') {
      mapData[sp.getString('date')!] = map['date'];
    }
    if (sp.getString('body') != null && sp.getString('body') != '') {
      mapData[sp.getString('body')!] = map['body'];
    }
    if (sp.getString('Sender') != null && sp.getString('Sender') != '') {
      mapData[sp.getString('Sender')!] = map['sender'];
    }
    if (sp.getString('servicecenter') != null &&
        sp.getString('servicecenter') != '') {
      mapData[sp.getString('servicecenter')!] = map['servicecenter'];
    }
    if (sp.getString('method') == 'get') {
      return await dio
          .get(url,
              queryParameters: mapData,
              options: Options(responseType: ResponseType.json, method: 'GET'))
          .then((response) {
        log(response.toString());
        return response;
      }).catchError((err) {
        if (err is DioError) {
          return err.response!;
        }
      });
    }
    if (sp.getString('method') == 'post') {
      if (token != '') {
        dio.options.headers['Authorization'] = 'Bearer $token';
        return await dio
            .post(url,
                data: dio_service.FormData.fromMap(mapData),
                options:
                    Options(responseType: ResponseType.json, method: 'POST'))
            .then((response) {
          log(response.toString());
          return response;
        }).catchError((err) {
          if (err is DioError) {
            return err.response!;
          }
        });
      } else {
        return await dio
            .post(url,
                data: dio_service.FormData.fromMap(mapData),
                options:
                    Options(responseType: ResponseType.json, method: 'POST'))
            .then((response) {
          log(response.toString());
          return response;
        }).catchError((err) {
          if (err is DioError) {
            return err.response!;
          }
        });
      }
    }
  }
}

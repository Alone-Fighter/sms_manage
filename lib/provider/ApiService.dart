import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends ChangeNotifier {
  openbox() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    number.text = sp.getString('number') ?? "";
    exp.text = sp.getString('exp') ?? "";
    select = sp.getBool('select') ?? false;
    Api.text = sp.getString('api') ?? '';
    selectRadio = sp.getString('method') ?? '';
    value = sp.getString('value') ?? '';
    dataDate = sp.getString('date') ?? '';
    body = sp.getString('body') ?? '';
    sender = sp.getString('Sender') ?? '';
    servicecenter = sp.getString('servicecenter') ?? '';
    textToken.text = sp.getString('token') ?? '';
    map = {
      'date': dataDate,
      'servicecenter': servicecenter,
      'Sender': sender,
      'body': body,
    };
    notifyListeners();
  }

  TextEditingController number = TextEditingController();
  TextEditingController exp = TextEditingController();
  TextEditingController Api = TextEditingController();
  TextEditingController textCommand = TextEditingController();
  TextEditingController textValue = TextEditingController();
  TextEditingController textToken = TextEditingController();

  bool isLoading = false;
  String num = '';
  String Exp = '';
  String api = '';
  String value = '';
  Map<String, dynamic> map = {};
  bool select = false;
  String dataDate = '';
  String servicecenter = '';
  String sender = '';
  String body = '';

  updateMap() {
    if (selectMethod == 'date') {
      map['date'] = textCommand.text;
    }
    if (selectMethod == 'servicecenter') {
      map['servicecenter'] = textCommand.text;
    }
    if (selectMethod == 'Sender') {
      map['Sender'] = textCommand.text;
    }
    if (selectMethod == 'body') {
      map['body'] = textCommand.text;
    }
    textCommand.text = '';
    selectMethod = '';
    notifyListeners();
  }

  removeMap() {
    map.remove(selectMethod);
    notifyListeners();
  }

  saveSetting() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('api', Api.text);
    sp.setString('method', selectRadio);
    sp.setString('token', textToken.text);
    if (map['date'] != null && map['date'] != '') {
      sp.setString('date', map['date']);
    }
    if (map['servicecenter'] != null && map['servicecenter'] != '') {
      sp.setString('servicecenter', map['servicecenter']);
    }
    if (map['Sender'] != null && map['Sender'] != '') {
      sp.setString('Sender', map['Sender']);
    }
    if (map['body'] != null && map['body'] != '') {
      sp.setString('body', map['body']);
    }
  }

  clickCheck(val) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("select", val!);
    select = val;
    notifyListeners();
  }

  String selectRadio = '';

  clickRadio(val) {
    selectRadio = val;
    notifyListeners();
  }

  String selectMethod = '';

  onclickMethod(val) {
    selectMethod = val;
    notifyListeners();
  }
}

abstract class Status {
  void error();

  void uploading();

  void uploaded();
}

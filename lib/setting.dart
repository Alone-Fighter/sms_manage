import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_manage/provider/ApiService.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setting'),
        ),
        body: Consumer<ApiService>(builder: (context, value, child) {
          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                value.clickRadio('post');
                              },
                              child: const Text('POST')),
                          Radio(
                              value: 'post',
                              groupValue: value.selectRadio,
                              onChanged: (val) => value.clickRadio(val)),
                          const SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                              onTap: () {
                                value.clickRadio('get');
                              },
                              child: const Text('GET')),
                          Radio(
                              value: 'get',
                              groupValue: value.selectRadio,
                              onChanged: (val) => value.clickRadio(val)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: value.selectRadio != '' ? true : false,
                    child: DelayedDisplay(
                      delay: const Duration(milliseconds: 500),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                spreadRadius: 0.8,
                                offset: const Offset(0, 1),
                              )
                            ]),
                        child: TextField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            hintText: 'Enter Api ',
                          ),
                          controller: value.Api,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: value.selectRadio != '' ? true : false,
                    child: DelayedDisplay(
                      delay: const Duration(milliseconds: 550),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                spreadRadius: 0.8,
                                offset: const Offset(0, 1),
                              )
                            ]),
                        child: TextField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            hintText: 'Enter Command ',
                          ),
                          controller: value.textCommand,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: value.selectRadio == 'post' ? true : false,
                    child: DelayedDisplay(
                      delay: const Duration(milliseconds: 600),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                spreadRadius: 0.8,
                                offset: const Offset(0, 1),
                              )
                            ]),
                        child: TextField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            hintText: 'Enter Token ',
                          ),
                          controller: value.textToken,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: value.selectRadio != '' ? true : false,
                    child: DelayedDisplay(
                      delay: const Duration(milliseconds: 600),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              value.onclickMethod('date');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Date'),
                                Radio(
                                    value: 'date',
                                    groupValue: value.selectMethod,
                                    onChanged: (val) =>
                                        value.onclickMethod(val)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              value.onclickMethod('servicecenter');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('ServiceCenter'),
                                Radio(
                                    value: 'servicecenter',
                                    groupValue: value.selectMethod,
                                    onChanged: (val) =>
                                        value.onclickMethod(val)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: value.selectRadio != '' ? true : false,
                    child: DelayedDisplay(
                      delay: const Duration(milliseconds: 600),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              value.onclickMethod('Sender');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Sender'),
                                Radio(
                                    value: 'Sender',
                                    groupValue: value.selectMethod,
                                    onChanged: (val) =>
                                        value.onclickMethod(val)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              value.onclickMethod('body');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Body'),
                                Radio(
                                    value: 'body',
                                    groupValue: value.selectMethod,
                                    onChanged: (val) =>
                                        value.onclickMethod(val)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: value.selectRadio != '' ? true : false,
                    child: DelayedDisplay(
                      delay: const Duration(milliseconds: 650),
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          child: const Text('Add'),
                          onPressed: () async {
                            value.updateMap();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: value.selectRadio != '' ? true : false,
                    child: DelayedDisplay(
                      delay: const Duration(milliseconds: 650),
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          child: const Text('Remove'),
                          onPressed: () async {
                            value.removeMap();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: value.selectRadio != '' ? true : false,
                    child: DelayedDisplay(
                      delay: const Duration(milliseconds: 650),
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          child: const Text('Save'),
                          onPressed: () async {
                            value.saveSetting();
                            // var response = await DioSevice().method2();
                            // print(response.data);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                      visible: value.selectRadio == '' ? false : true,
                      child: Text(value.map.toString())),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

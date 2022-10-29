import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_manage/log.dart';
import 'package:sms_manage/provider/ApiService.dart';
import 'package:sms_manage/servies/dio_services.dart';
import 'package:sms_manage/setting.dart';
import 'package:telephony/telephony.dart';
import 'package:provider/provider.dart';

onBackgroundMessage(SmsMessage message) {
  _MyHomePageState().filterBack(message);
  debugPrint("onBackgroundMessage called");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
  service.invoke("setAsBackground");
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  String number = '';
  String exp = '';
  bool select = false;

  SharedPreferences preferences = await SharedPreferences.getInstance();
  exp = preferences.getString("exp") ?? '';
  number = preferences.getString("number") ?? '';
  select = preferences.getBool('select') ?? false;
  List<String> list = ['Service Start'];
  preferences.setStringList('log', list);

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    final services = FlutterBackgroundService();
    var isRunning = await services.isRunning();
    if (isRunning) {
      _MyHomePageState().running = true;
    } else {
      _MyHomePageState().running = false;
    }
    await preferences.reload();
    exp = preferences.getString("exp") ?? '';
    number = preferences.getString("number") ?? '';
    select = preferences.getBool("select") ?? false;

    /// you can see this log in logcat
    if (kDebugMode) {
      print('FLUTTER BACKGROUND SERVICE: $exp + $number + $select');
    }

    service.invoke(
      'update',
      {
        "number": number,
        "exp": exp,
        "select": select,
      },
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ApiService(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  @override
  late BuildContext context;

  //values
  Map<String, dynamic> map = {};
  final telephony = Telephony.instance;
  String num = '';
  String exp = '';
  bool? select = false;
  bool running = false;

  //
  @override
  void initState() {
    _connect();
    initPlatformState();
    super.initState();
  }

  onMessage(message) async {
    filter(message);
  }

  onBack(message) {
    filterBack(message);
  }

  Future<void> initPlatformState() async {
    Future.delayed(const Duration(seconds: 2), () {
      FlutterBackgroundService().invoke("setAsBackground");
      Provider.of<ApiService>(context, listen: false).openbox();
    });
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage,
          onBackgroundMessage: onBackgroundMessage,
          listenInBackground: true);
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
          leading: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Setting()));
            },
            child: const Icon(Icons.settings),
          ),
        ),
        body: Consumer<ApiService>(
          builder: (context, value, child) {
            return !running
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        StreamBuilder<Map<String, dynamic>?>(
                          stream: FlutterBackgroundService().on('update'),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade300,
                                                        blurRadius: 5,
                                                        spreadRadius: 0.8,
                                                        offset:
                                                            const Offset(0, 1),
                                                      )
                                                    ]),
                                                child: TextField(
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                    hintText:
                                                        'enter regular exception for number',
                                                  ),
                                                  controller: value.number,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors
                                                            .grey.shade300,
                                                        blurRadius: 5,
                                                        spreadRadius: 0.8,
                                                        offset:
                                                            const Offset(0, 1),
                                                      )
                                                    ]),
                                                child: TextField(
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                    hintText:
                                                        'enter regular exception for text',
                                                  ),
                                                  controller: value.exp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('And'),
                                            Checkbox(
                                                value: value.select,
                                                onChanged: (val) async {
                                                  value.clickCheck(val);
                                                })
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  child: const Text('Save'),
                                  onPressed: () async {
                                    final SharedPreferences sp =
                                        await SharedPreferences.getInstance();
                                    sp.setString("number", value.number.text);
                                    sp.setString("exp", value.exp.text);
                                    sp.reload();
                                    sp.reload();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          width: double.infinity,
                          height: 400,
                          child: const Center(child: LogView()),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
        floatingActionButton: Consumer<ApiService>(
          builder: (context, value, child) {
            return FloatingActionButton(
              onPressed: () async {},
              child: !running
                  ? const Icon(Icons.play_arrow)
                  : const Icon(Icons.pause),
            );
          },
        ),
      ),
    );
  }

  Future<void> _connect() async {
    const config = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Running',
      notificationText: 'Running',
      notificationIcon: AndroidResource(name: 'background_icon'),
      notificationImportance: AndroidNotificationImportance.Default,
      enableWifiLock: true,
    );
    var hasPermissions = await FlutterBackground.hasPermissions;
    if (!hasPermissions) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('Permissions needed'),
                content: const Text(
                    'Shortly the OS will ask you for permission to execute this app in the background. This is required in order to receive chat messages when the app is not in the foreground.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ]);
          });
    }
    hasPermissions = await FlutterBackground.initialize(androidConfig: config);
    if (hasPermissions) {
      if (hasPermissions) {
        final backgroundExecution =
            await FlutterBackground.enableBackgroundExecution();
      }
    }
  }

  void filter(SmsMessage message) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.reload();
    String exp = preferences.getString("exp") ?? '';
    String number = preferences.getString("number") ?? '';
    bool? op = preferences.getBool('select') ?? false;
    String method = preferences.getString('method') ?? '';
    String api = preferences.getString('api') ?? '';
    RegExp body = RegExp(exp);
    RegExp numberExp = RegExp(number);
    if (number == '' && exp == '') {
      Log().create('Empty');
      return;
    }
    if (number == '') {
      map = {
        'date': message.date,
        'body': message.body,
        'sender': message.address,
        'servicecenter': message.serviceCenterAddress,
      };
      Log().create(
          '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = ${body.hasMatch(message.body!)} ');
      var response = await DioSevice().method(method, api, map);
      Log().create('data = ${response.data}');
      return;
    }
    if (exp == '') {
      map = {
        'date': message.date,
        'body': message.body,
        'sender': message.address,
        'servicecenter': message.serviceCenterAddress,
      };
      Log().create(
          '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = ${body.hasMatch(message.body!)} ');
      var response = await DioSevice().method(method, api, map);
      Log().create('data = ${response.data}');
      return;
    }
    if (exp != '' && number != '') {
      if (op) {
        if (body.hasMatch(message.body!) &&
            numberExp.hasMatch(message.address!)) {
          map = {
            'date': message.date,
            'body': message.body,
            'sender': message.address,
            'servicecenter': message.serviceCenterAddress,
          };
          Log().create(
              '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = true ');
          var response = await DioSevice().method(method, api, map);
          Log().create('data = ${response.data}');
          return;
        } else {
          map = {
            'date': message.date,
            'body': message.body,
            'sender': message.address,
            'servicecenter': message.serviceCenterAddress,
          };
          Log().create(
              '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = false ');
          var response = await DioSevice().method(method, api, map);
          Log().create('data = ${response.data}');
          return;
        }
      }
      if (!op) {
        if (body.hasMatch(message.body!) ||
            numberExp.hasMatch(message.address!)) {
          map = {
            'date': message.date,
            'body': message.body,
            'sender': message.address,
            'servicecenter': message.serviceCenterAddress,
          };
          Log().create(
              '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = true ');
          var response = await DioSevice().method(method, api, map);
          Log().create('data = ${response.data}');
          return;
        } else {
          map = {
            'date': message.date,
            'body': message.body,
            'sender': message.address,
            'servicecenter': message.serviceCenterAddress,
          };
          Log().create(
              '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = false ');
          var response = await DioSevice().method(method, api, map);
          Log().create('data = ${response.data}');
          return;
        }
      }
    }
  }

  void filterBack(SmsMessage message) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    String exp = preferences.getString("exp") ?? '';
    String number = preferences.getString("number") ?? '';
    bool op = preferences.getBool('select') ?? false;
    String method = preferences.getString('method') ?? '';
    String api = preferences.getString('api') ?? '';
    RegExp body = RegExp(exp);
    RegExp numberExp = RegExp(number);
    if (number == '' && exp == '') {
      Log().create('Empty');
      return;
    }
    if (number == '') {
      map = {
        'date': message.date,
        'body': message.body,
        'sender': message.address,
        'servicecenter': message.serviceCenterAddress,
      };
      Log().create(
          '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = ${body.hasMatch(message.body!)} ');
      var response = await DioSevice().method(method, api, map);
      Log().create('data = ${response.data}');
      return;
    }
    if (exp == '') {
      map = {
        'date': message.date,
        'body': message.body,
        'sender': message.address,
        'servicecenter': message.serviceCenterAddress,
      };
      Log().create(
          '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = ${body.hasMatch(message.body!)} ');
      var response = await DioSevice().method(method, api, map);
      Log().create('data = ${response.data}');
      return;
    }
    if (exp != '' && number != '') {
      if (op) {
        if (body.hasMatch(message.body!) &&
            numberExp.hasMatch(message.address!)) {
          map = {
            'date': message.date,
            'body': message.body,
            'sender': message.address,
            'servicecenter': message.serviceCenterAddress,
          };
          Log().create(
              '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = true ');
          var response = await DioSevice().method(method, api, map);
          Log().create('data = ${response.data}');
          return;
        } else {
          map = {
            'date': message.date,
            'body': message.body,
            'sender': message.address,
            'servicecenter': message.serviceCenterAddress,
          };
          Log().create(
              '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = false ');
          var response = await DioSevice().method(method, api, map);
          Log().create('data = ${response.data}');
          return;
        }
      }
      if (!op) {
        if (body.hasMatch(message.body!) ||
            numberExp.hasMatch(message.address!)) {
          map = {
            'date': message.date,
            'body': message.body,
            'sender': message.address,
            'servicecenter': message.serviceCenterAddress,
          };
          Log().create(
              '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = true ');
          var response = await DioSevice().method(method, api, map);
          Log().create('data = ${response.data}');
          return;
        } else {
          map = {
            'date': message.date,
            'body': message.body,
            'sender': message.address,
            'servicecenter': message.serviceCenterAddress,
          };
          Log().create(
              '${message.body} + ${message.address} + ${message.date} + ${message.serviceCenterAddress} + result = false ');
          var response = await DioSevice().method(method, api, map);
          Log().create('data = ${response.data}');
          return;
        }
      }
    }
  }
}

class LogView extends StatefulWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.reload();
      logs = sp.getStringList('log') ?? [];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs.elementAt(index);
        return Text(
          log,
          textDirection: TextDirection.ltr,
        );
      },
    );
  }
}

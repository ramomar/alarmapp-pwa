import 'package:alarmapp_pwa/alarm_status/alarm_status_page.dart';
import 'package:alarmapp_pwa/alarm_status/bloc/alarm_status_bloc.dart';
import 'package:alarmapp_pwa/repositories/alarm_system_repository.dart';
import 'package:alarmapp_pwa/settings/settings_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Alarmapp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          useMaterial3: true,
        ),
        home: const TabNavigation());
  }
}

class TabNavigation extends StatefulWidget {
  const TabNavigation({super.key});

  @override
  State<TabNavigation> createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  _TabNavigationState() {
    // hack so I don't have to build a login screen hehe
    // access token and device id are going to come from the URL (:
    final queryParams = Uri.base.queryParameters;

    accessToken = queryParams['accessToken'] ?? '';
    deviceId = queryParams['deviceId'] ?? '';
  }

  late String accessToken;
  late String deviceId;

  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) =>
          AlarmSystemRepository(accessToken: accessToken, deviceId: deviceId),
      child: BlocProvider(
        create: (BuildContext context) {
          final bloc = AlarmStatusBloc(context.read<AlarmSystemRepository>());
          bloc.add(StartAlarmStateStreamRequested());

          return bloc;
        },
        child: BlocBuilder<AlarmStatusBloc, AlarmStatusState>(
          builder: (context, state) {
            return FutureBuilder<NotificationSettings>(
              future: FirebaseMessaging.instance.getNotificationSettings(),
              builder: (BuildContext context,
                  AsyncSnapshot<NotificationSettings> snapshot) {
                if (snapshot.hasData &&
                    snapshot.data?.authorizationStatus !=
                        AuthorizationStatus.authorized) {
                  return Center(
                    child: FilledButton(
                      onPressed: () async {
                        await FirebaseMessaging.instance.requestPermission(
                          alert: true,
                          announcement: false,
                          badge: true,
                          carPlay: true,
                          criticalAlert: true,
                          provisional: false,
                          sound: true,
                        );

                        setState(() {});
                      },
                      child: const Text('Comenzar'),
                    ),
                  );
                }

                if (state is MonitoredState) {
                  return Scaffold(
                      bottomNavigationBar: NavigationBar(
                        onDestinationSelected: (int index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                        },
                        selectedIndex: _currentPageIndex,
                        destinations: const <Widget>[
                          NavigationDestination(
                            icon: Icon(Icons.fact_check),
                            label: 'Resumen',
                          ),
                          NavigationDestination(
                            icon: Icon(Icons.settings),
                            label: 'Configuración',
                          ),
                        ],
                      ),
                      body: <Widget>[
                        const AlarmStatusPage(),
                        const SettingsPage(),
                      ][_currentPageIndex]);
                }

                return const Center(
                  child: CircularProgressIndicator(
                    value: null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

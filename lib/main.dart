import 'package:alarmapp_pwa/alarm_status/alarm_status_page.dart';
import 'package:alarmapp_pwa/alarm_status/bloc/alarm_status_bloc.dart';
import 'package:alarmapp_pwa/repositories/alarm_system_repository.dart';
import 'package:alarmapp_pwa/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
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
      home: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Provider<SharedPreferences>(
                create: (_) => snapshot.data!,
                child: const TabNavigation(),
              );
            }

            return const Text('...');
          }),
    );
  }
}

class TabNavigation extends StatefulWidget {
  const TabNavigation({super.key});

  @override
  State<TabNavigation> createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  _TabNavigationState();

  int _currentPageIndex = 0;
  final deviceIdFieldController = TextEditingController();
  final accessTokenFieldController = TextEditingController();

  @override
  void dispose() {
    deviceIdFieldController.dispose();
    accessTokenFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<SharedPreferences>();

    if (!prefs.containsKey('deviceId') || !prefs.containsKey('accessToken')) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50),
          child: SizedBox(
            child: Center(
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: deviceIdFieldController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'deviceId',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: accessTokenFieldController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'accessToken',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: _handleFormSubmit,
                        child: const Text('Comenzar'))
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RepositoryProvider(
      create: (context) {
        return AlarmSystemRepository(
          accessToken: prefs.getString('accessToken')!,
          deviceId: prefs.getString('deviceId')!);
      },
      child: BlocProvider(
        create: (BuildContext context) {
          final bloc = AlarmStatusBloc(context.read<AlarmSystemRepository>());
          bloc.add(StartAlarmStateStreamRequested());

          return bloc;
        },
        child: BlocBuilder<AlarmStatusBloc, AlarmStatusState>(
          builder: (context, state) {
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
        ),
      ),
    );
  }

  void _handleFormSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final sanitizedDeviceId = deviceIdFieldController.text.trim();
    final sanitizedAccessToken = accessTokenFieldController.text.trim();

    if (sanitizedDeviceId.isEmpty || sanitizedAccessToken.isEmpty) {
      return;
    }

    await prefs.setString('deviceId', sanitizedDeviceId);
    await prefs.setString('accessToken', sanitizedAccessToken);

    setState(() {});
  }
}

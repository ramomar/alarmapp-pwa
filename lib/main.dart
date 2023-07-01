import 'package:alarmapp_pwa/alarm_status_page.dart';
import 'package:alarmapp_pwa/settings_page.dart';
import 'package:flutter/material.dart';

void main() {
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
      home: const TabNavigation(),
    );
  }
}

class TabNavigation extends StatefulWidget {
  const TabNavigation({super.key});

  @override
  State<TabNavigation> createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
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
}

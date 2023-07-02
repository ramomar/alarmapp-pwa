import 'package:alarmapp_pwa/alarm_status/bloc/alarm_status_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Probar sirena'),
          OutlinedButton(
            child: const Text('Probar'),
            onPressed: () =>
                context.read<AlarmStatusBloc>().add(SirenTestRequested()),
          ),
        ],
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.only(left: 28, right: 28, top: 32),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(child: items[index]);
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

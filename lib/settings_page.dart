import 'package:flutter/material.dart';

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
            onPressed: () => {},
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

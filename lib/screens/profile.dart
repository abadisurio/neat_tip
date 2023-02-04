import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/app_state.dart';
import 'package:neat_tip/bloc/neattip_user.dart';
import 'package:neat_tip/models/neattip_user.dart';

const appConfigs = [
  {
    "name": "Kurangi Animasi",
    "value": true,
  },
  {
    "name": "Kurangi Animasi",
    "value": true,
  },
  {
    "name": "Kurangi Animasi",
    "value": true,
  },
];

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyText1;
    final appStateCubit = context.watch<AppStateCubit>();
    // BlocProvider.of<AppStateCubit>(context, listen: true);

    return Scaffold(
      body: BlocBuilder<NeatTipUserCubit, NeatTipUser?>(
          builder: (context, neatTipUser) {
        // return BlocProvider.of<AppStateCubit>(context).updateConfig();
        return ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                // child: Text(state!.displayName
                child: Text('Abadi Suryo'
                    .split(' ')
                    .map((e) => e.substring(0, 1))
                    .join('')
                    .toUpperCase()),
              ),
              title: Text(
                'Abadi Suryo',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              subtitle: const Text('Akun personal'),
              trailing: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profileedit');
                  },
                  child: const Text('Ubah')),
            ),
            const Divider(
              indent: 12,
              endIndent: 12,
            ),
            ListView.builder(
              itemCount: appStateCubit.state.configs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final configItem = appStateCubit.state.configs[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(IconData(configItem['icon'],
                        fontFamily: 'MaterialIcons')),
                  ),
                  title: Text(
                    configItem['name'] as String,
                    style: style,
                  ),
                  trailing: Switch(
                    value: configItem['value'] as bool,
                    onChanged: (bool value) {
                      log('$index $value');
                      appStateCubit.updateConfig(index, value);
                      // This is called when the user toggles the switch.
                      // setState(() {
                      //   light = value;
                      // });
                    },
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}

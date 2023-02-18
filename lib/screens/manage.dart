import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class Manage extends StatelessWidget {
  const Manage({super.key});

  _askToSignOut(context) async {
    await showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text('Keluar dari akun'),
            content: const Text('Anda yakin?'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Batal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Keluar'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/signout');
                },
              ),
            ],
          );
        }));
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyText1;
    final appStateCubit = context.watch<AppStateCubit>();
    // BlocProvider.of<AppStateCubit>(context, listen: true);

    return Scaffold(
      body: BlocBuilder<NeatTipUserCubit, NeatTipUser?>(
          builder: (context, neatTipUser) {
        final nameInitial =
            (context.watch<NeatTipUserCubit>().state?.displayName ??
                    'Neat Tip User')
                .split(' ')
                .map((e) => (e.isNotEmpty ? e.substring(0, 1) : ''))
                .join('')
                .toUpperCase();
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Akun Saya',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                  radius: 32,
                  child: FirebaseAuth.instance.currentUser?.photoURL != null
                      // ? null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                FirebaseAuth.instance.currentUser?.photoURL ??
                                    '',
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        )
                      : Text(
                          (nameInitial.length > 3
                              ? nameInitial.substring(0, 3)
                              : nameInitial),
                        )
                  // child: Text(currentUser!.displayName
                  //     child:
                  ),
              title: Text(
                context.watch<NeatTipUserCubit>().state?.displayName ??
                    'Neat Tip User',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              subtitle: Text(
                  context.watch<NeatTipUserCubit>().state?.role ?? 'Pengguna'),
              trailing: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profileedit');
                  },
                  child: const Text('Ubah')),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pengaturan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appStateCubit.state.visibleMembers.entries.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final configItem =
                    appStateCubit.state.visibleMembers.entries.toList()[index];
                return ListTile(
                  title: Text(
                    configItem.value['name'],
                    style: style,
                  ),
                  trailing: Switch(
                    value: configItem.value['value'] ?? false,
                    onChanged: (bool value) {
                      log('${configItem.key} $value');
                      appStateCubit.updateConfig(configItem.key, value);
                      // This is called when the user toggles the switch.
                      // setState(() {
                      //   light = value;
                      // });
                    },
                  ),
                );
              },
            ),
            ListTile(
              onTap: () => _askToSignOut(context),
              title: Text(
                'Keluarkan Akun',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        );
      }),
    );
  }
}

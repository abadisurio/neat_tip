import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/neattip_user.dart';
import 'package:neat_tip/models/neattip_user.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NeatTipUserCubit, NeatTipUser?>(
          builder: (context, state) {
        return ListView(
          children: [
            ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {},
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline_outlined),
                    ),
                    title: Text(
                      'Rincian Akun',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    trailing: const Icon(Icons.chevron_right),
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

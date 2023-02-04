import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neat_tip/bloc/transaction_list.dart';
import 'package:neat_tip/models/transactions.dart';
import 'package:neat_tip/widgets/dashboard_menu.dart';
import 'package:neat_tip/widgets/peek_and_pop_able.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // isScreenActive = true;
  }

  @override
  void deactivate() {
    // log('deact');
    super.deactivate();
  }

  seeMoreTransaction() {
    log('message');
    Navigator.pushNamed(context, '/transactions');
  }

  @override
  Widget build(BuildContext context) {
    // bool isScreenActive = true;
    // log('isScreenActive $isScreenActive');
    // final routeNow = ModalRoute.of(context)?.settings.name;
    // Navigator.of(context).
    // log('$routeNow');
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            SizedBox(
              // color: Colors.red,
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: const [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 30),
                      child: DashboardMenu(),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Terbaru'),
                TextButton(
                    onPressed: seeMoreTransaction,
                    child: const Text('Lihat Semua')),
              ],
            ),
            const Divider(
              // height: 1,
              thickness: 2,
            ),
            BlocBuilder<TransactionsListCubit, List<Transactions>>(
                builder: (context, transactionsList) {
              if (transactionsList.isEmpty) {
                return const Center(child: Text('Belum ada transaksi!'));
              }
              return ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: ((context, index) {
                    return Card(
                        clipBehavior: Clip.hardEdge,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          //set border radius more than 50% of height and width to make circle
                        ),
                        elevation: 0,
                        child: PeekAndPopable(
                          child: ListTile(
                            // dense: true,
                            leading: const CircleAvatar(
                              child: Icon(
                                Icons.motorcycle,
                              ),
                            ),
                            title: const Text('Kurnia Motor'),
                            subtitle: const Text('Dititipkan • Hari ini'),
                            trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rp6000',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  Text(
                                    'Ditahan',
                                    style: Theme.of(context).textTheme.caption,
                                  )
                                ]),
                          ),
                        ));
                  }));
            })
          ],
        ),
      ),
    );
  }
}

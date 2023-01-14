import 'package:flutter/material.dart';

class DashboardWallet extends StatefulWidget {
  const DashboardWallet({super.key});

  @override
  State<DashboardWallet> createState() => _DashboardWalletState();
}

class _DashboardWalletState extends State<DashboardWallet> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("EternalExpend"),
                Text("Total Saldo"),
                Text("Rp13.521",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
              ],
            ),
            Text("EternalExpend"),
            Text("Total Saldo"),
          ],
        ));
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:neat_tip/screens/loading_window.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionWindow extends StatefulWidget {
  final VoidCallback? onAllowedAll;
  final bool showDoneButton;
  const PermissionWindow(
      {super.key, this.onAllowedAll, this.showDoneButton = true});

  @override
  State<PermissionWindow> createState() => _PermissionWindowState();
}

final List<Map<String, dynamic>> serviceList = [
  {'name': 'Kameraaa', 'type': Permission.camera}
];

class _PermissionWindowState extends State<PermissionWindow> {
  Map<Permission, PermissionStatus> permissionStatus = {};
  bool isChecking = true;
  bool isAllAllowed = true;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    setState(() {
      isAllAllowed = true;
    });
    for (var service in serviceList) {
      final Permission permission = service['type'];
      final status = await permission.status;
      permissionStatus[permission] = status;
      if (!status.isGranted) {
        setState(() {
          isAllAllowed = false;
        });
      }
    }

    log('widget.onAllowedAll ${widget.onAllowedAll}');
    if (widget.onAllowedAll != null && isAllAllowed) {
      widget.onAllowedAll!();
    }

    setState(() {
      isChecking = false;
    });
  }

  Future<void> requestAccess(Permission type) async {
    final camera = await type.request();
    setState(() {
      permissionStatus[type] = camera;
    });
    await checkPermission();
  }

  returnToApp() {
    Navigator.pop(context, isAllAllowed);
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) return const LoadingWindow();

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, isAllAllowed);
          return isAllAllowed;
        },
        child: SafeArea(
          child: ListView.builder(
              itemCount: serviceList.length + 2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: const [
                      Text(
                          'Neat Tip memerlukan akses berikut untuk dapat berjalan'),
                      Text('Izinkan permintaan untuk melanjutkan'),
                    ],
                  );
                }
                if (index == serviceList.length + 1) {
                  return isAllAllowed && widget.showDoneButton
                      ? ElevatedButton(
                          onPressed: returnToApp, child: const Text('selesai'))
                      : const Center(
                          child: Text('belom'),
                        );
                }
                final service = serviceList[index - 1];
                final isGranted = permissionStatus[service['type']]!.isGranted;
                return ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(service['name']),
                  subtitle:
                      Text(isGranted ? "sudah diizinkan" : "tidak diizinkan"),
                  trailing: isGranted
                      ? null
                      : ElevatedButton(
                          onPressed: () {
                            requestAccess(service['type']);
                          },
                          child: const Text("Minta Akses"),
                        ),
                );
              }),
        ),
      ),
    );
  }
}

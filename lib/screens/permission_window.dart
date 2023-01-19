import 'package:flutter/material.dart';
import 'package:neat_tip/screens/loading_window.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionWidnow extends StatefulWidget {
  const PermissionWidnow({super.key});

  @override
  State<PermissionWidnow> createState() => _PermissionWidnowState();
}

final List<Map<String, dynamic>> serviceList = [
  {'name': 'Kameraaa', 'type': Permission.camera}
];

class _PermissionWidnowState extends State<PermissionWidnow> {
  Map<Permission, PermissionStatus> permissionStatus = {};
  bool isChecking = true;
  bool isAllAllowed = true;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    for (var service in serviceList) {
      final Permission permission = service['type'];
      final status = await permission.status;
      permissionStatus[permission] = status;
      setState(() {
        if (!status.isGranted) {
          isAllAllowed = false;
        }
      });
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
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) return const LoadingWindow();

    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
            itemCount: serviceList.length + 1,
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
              if (index == serviceList.length && isAllAllowed) {
                return const Text('boleh semua');
              }
              final service = serviceList[index - 1];
              final isGranted = permissionStatus[service['type']]!.isGranted;
              return ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(service['name']),
                subtitle:
                    Text(isGranted ? "sudah diizinkan" : "tidak diizinkan"),
                trailing: isGranted
                    ? null
                    : ElevatedButton(
                        onPressed: () {
                          requestAccess(service['type']);
                        },
                        child: Text("Minta Akses"),
                      ),
              );
            }),
      ),
    );
  }
}

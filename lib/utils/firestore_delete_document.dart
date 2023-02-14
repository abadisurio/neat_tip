import 'dart:developer';
import 'package:firebase_storage/firebase_storage.dart';

deleteFolder(path) {
  final ref = FirebaseStorage.instance.ref(path);
  ref.listAll().then((dir) {
    for (var fileRef in dir.items) {
      deleteFile(ref.fullPath, fileRef.name);
    }
    for (var folderRef in dir.prefixes) {
      deleteFolder(folderRef.fullPath);
    }
  }).catchError((error, stackTrace) {
    log('$error');
  });
}

deleteFile(pathToFile, fileName) {
  final ref = FirebaseStorage.instance.ref(pathToFile);
  final childRef = ref.child(fileName);
  childRef.delete();
}

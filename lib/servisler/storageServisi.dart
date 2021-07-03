import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {
  StorageReference _storage = FirebaseStorage.instance.ref();
  late String resimId;
  Future<String> gonderiResmiYukle(File resimDosyasi) async {
    resimId = Uuid().v4();
    StorageUploadTask yuklemeYoneticisi = _storage
        .child("resimler")
        .child("gonderiler")
        .child("gonderi$resimId.jpg")
        .putFile(resimDosyasi);
    StorageTaskSnapshot snapshot = await yuklemeYoneticisi.onComplete;
    String yuklenenResimUrl = await snapshot.ref.getDownloadURL();
    return yuklenenResimUrl;
  }

  gonderiResmiSil(String gonderiResmiUrl) {
    RegExp arama = RegExp(r"gonderi_.+\.jpg");
    var eslesme = arama.firstMatch(gonderiResmiUrl);
    String? dosyaAdi = eslesme?[0];
    if (dosyaAdi != null) {
      _storage.child("resimler/gonderiler/$dosyaAdi").delete();
    }
  }
}
